import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';

part 'premium_iap_service.g.dart';

class PremiumIapResult {
  const PremiumIapResult._({
    required this.isSuccess,
    this.errorMessage,
    this.purchase,
  });

  const PremiumIapResult.success({PurchaseDetails? purchase})
    : this._(isSuccess: true, purchase: purchase);

  const PremiumIapResult.failure(String message)
    : this._(isSuccess: false, errorMessage: message);

  final bool isSuccess;
  final String? errorMessage;
  final PurchaseDetails? purchase;
}

@Riverpod(keepAlive: true)
class PremiumIapService extends _$PremiumIapService {
  @override
  void build() {
    return;
  }

  InAppPurchase get _iap => InAppPurchase.instance;

  Future<bool> get isSupported async {
    if (kIsWeb) return false;

    final isIosOrAndroid =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    if (!isIosOrAndroid) return false;

    return _iap.isAvailable();
  }

  Future<PremiumIapResult> purchasePlan(PremiumPlan plan) async {
    try {
      if (!await isSupported) {
        return const PremiumIapResult.failure(
          'In-app purchases are only available on iOS and Android.',
        );
      }

      final productId = plan.iapProductId;
      final response = await _iap.queryProductDetails({productId});

      if (response.error != null) {
        return PremiumIapResult.failure(response.error!.message);
      }

      if (response.productDetails.isEmpty ||
          response.notFoundIDs.contains(productId)) {
        return PremiumIapResult.failure(
          'Subscription product is not configured or not available: $productId',
        );
      }

      final product = _selectProductForPlan(
        response.productDetails,
        plan,
      );

      final purchaseParam = _createPurchaseParam(
        product: product,
        plan: plan,
      );

      final completer = Completer<PremiumIapResult>();
      late final StreamSubscription<List<PurchaseDetails>> streamSubscription;
      Timer? timeout;

      Future<void> finish(PremiumIapResult result) async {
        if (!completer.isCompleted) {
          completer.complete(result);
        }

        timeout?.cancel();
        await streamSubscription.cancel();
      }

      streamSubscription = _iap.purchaseStream.listen(
        (purchases) async {
          for (final purchase in purchases.where(
            (item) => item.productID == productId,
          )) {
            try {
              switch (purchase.status) {
                case PurchaseStatus.pending:
                  continue;

                case PurchaseStatus.error:
                  await finish(
                    PremiumIapResult.failure(
                      purchase.error?.message ??
                          'Your purchase could not be completed. Please try again.',
                    ),
                  );
                  return;

                case PurchaseStatus.purchased:
                case PurchaseStatus.restored:
                  final verified = _hasVerificationPayload(purchase);

                  if (!verified) {
                    await finish(
                      const PremiumIapResult.failure(
                        'Purchase verification failed. Please contact support.',
                      ),
                    );
                    return;
                  }

                  if (purchase.pendingCompletePurchase) {
                    await _iap.completePurchase(purchase);
                  }

                  await finish(
                    PremiumIapResult.success(purchase: purchase),
                  );
                  return;

                case PurchaseStatus.canceled:
                  await finish(
                    const PremiumIapResult.failure(
                      'Purchase cancelled by user.',
                    ),
                  );
                  return;
              }
            } on PlatformException catch (e) {
              await finish(PremiumIapResult.failure(_mapPlatformError(e)));
              return;
            } on MissingPluginException {
              await finish(
                const PremiumIapResult.failure(
                  'In-app purchase plugin is not ready. Fully restart the app and try again.',
                ),
              );
              return;
            } catch (e) {
              await finish(
                PremiumIapResult.failure(
                  'Purchase handling failed unexpectedly: $e',
                ),
              );
              return;
            }
          }
        },
        onError: (Object error) async {
          await finish(
            PremiumIapResult.failure('Purchase stream error: $error'),
          );
        },
      );

      timeout = Timer(const Duration(minutes: 3), () async {
        await finish(
          const PremiumIapResult.failure(
            'Purchase timed out. Please try again.',
          ),
        );
      });

      final launched = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!launched) {
        await finish(
          const PremiumIapResult.failure(
            'Could not launch store purchase flow.',
          ),
        );
      }

      return completer.future;
    } on PlatformException catch (e) {
      return PremiumIapResult.failure(_mapPlatformError(e));
    } on MissingPluginException {
      return const PremiumIapResult.failure(
        'In-app purchase plugin is not ready. Fully restart the app and try again.',
      );
    } catch (e) {
      return PremiumIapResult.failure(
        'In-app purchase failed unexpectedly: $e',
      );
    }
  }

  Future<PremiumIapResult> restorePurchases() async {
    try {
      if (!await isSupported) {
        return const PremiumIapResult.failure(
          'Restore purchases is only available on iOS and Android.',
        );
      }

      await _iap.restorePurchases();

      return const PremiumIapResult.success();
    } on PlatformException catch (e) {
      return PremiumIapResult.failure(_mapPlatformError(e));
    } on MissingPluginException {
      return const PremiumIapResult.failure(
        'In-app purchase plugin is not ready. Fully restart the app and try again.',
      );
    } catch (e) {
      return PremiumIapResult.failure('Restore purchases failed: $e');
    }
  }

  ProductDetails _selectProductForPlan(
    List<ProductDetails> products,
    PremiumPlan plan,
  ) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidProduct = _selectAndroidProductForBasePlan(
        products,
        plan.googlePlayBasePlanId,
      );

      if (androidProduct == null) {
        throw StateError(
          'No Google Play base plan found for "${plan.googlePlayBasePlanId}". '
          'Check that the base plan is active in Play Console.',
        );
      }

      return androidProduct;
    }

    return products.firstWhere(
      (product) => product.id == plan.iapProductId,
      orElse: () => products.first,
    );
  }

  GooglePlayProductDetails? _selectAndroidProductForBasePlan(
    List<ProductDetails> products,
    String basePlanId,
  ) {
    for (final product in products.whereType<GooglePlayProductDetails>()) {
      final offer = _subscriptionOfferFor(product);

      if (offer?.basePlanId == basePlanId) {
        return product;
      }
    }

    return null;
  }

  PurchaseParam _createPurchaseParam({
    required ProductDetails product,
    required PremiumPlan plan,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android &&
        product is GooglePlayProductDetails) {
      final offerToken = product.offerToken;

      if (offerToken == null || offerToken.trim().isEmpty) {
        throw StateError(
          'Missing Google Play offer token for base plan '
          '"${plan.googlePlayBasePlanId}".',
        );
      }

      return GooglePlayPurchaseParam(
        productDetails: product,
        offerToken: offerToken,
      );
    }

    return PurchaseParam(productDetails: product);
  }

  SubscriptionOfferDetailsWrapper? _subscriptionOfferFor(
    GooglePlayProductDetails product,
  ) {
    final subscriptionIndex = product.subscriptionIndex;
    final offers = product.productDetails.subscriptionOfferDetails;

    if (subscriptionIndex == null || offers == null) {
      return null;
    }

    if (subscriptionIndex < 0 || subscriptionIndex >= offers.length) {
      return null;
    }

    return offers[subscriptionIndex];
  }

  bool _hasVerificationPayload(PurchaseDetails purchase) {
    return purchase.verificationData.serverVerificationData.trim().isNotEmpty;
  }

  String _mapPlatformError(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();

    if (code == 'channel-error' ||
        message.contains('unable to establish connection on channel')) {
      return 'Google Play Billing is not available on this app instance. '
          'Install the app from a Play testing track on a Play-enabled device, '
          'then fully restart the app and try again.';
    }

    if (code.contains('billing_unavailable')) {
      return 'Google Play Billing is unavailable on this device/account.';
    }

    if (code.contains('item_unavailable')) {
      return 'This subscription product is not available for your account/region yet.';
    }

    if (code.contains('user_canceled')) {
      return 'Purchase cancelled by user.';
    }

    return error.message ?? 'In-app purchase could not be started.';
  }
}
