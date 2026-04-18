import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sport_connect/features/payments/models/premium_plan.dart';

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

class PremiumIapService {
  PremiumIapService({InAppPurchase? inAppPurchase})
    : _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final InAppPurchase _inAppPurchase;

  bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  Future<PremiumIapResult> purchasePlan(PremiumPlan plan) async {
    try {
      if (!isSupportedPlatform) {
        return const PremiumIapResult.failure(
          'In-app purchases are only available on iOS and Android.',
        );
      }

      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        return const PremiumIapResult.failure(
          'Store is currently unavailable. Please try again later.',
        );
      }

      final productId = plan.iapProductId;
      final response = await _inAppPurchase.queryProductDetails({productId});

      if (response.error != null) {
        return PremiumIapResult.failure(response.error!.message);
      }

      if (response.productDetails.isEmpty ||
          response.notFoundIDs.contains(productId)) {
        return PremiumIapResult.failure(
          'Subscription product is not configured: $productId',
        );
      }

      final product = response.productDetails.firstWhere(
        (detail) => detail.id == productId,
        orElse: () => response.productDetails.first,
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

      streamSubscription = _inAppPurchase.purchaseStream.listen(
        (purchases) async {
          for (final purchase in purchases.where(
            (item) => item.productID == productId,
          )) {
            try {
              if (purchase.status == PurchaseStatus.pending) {
                continue;
              }

              if (purchase.pendingCompletePurchase) {
                await _inAppPurchase.completePurchase(purchase);
              }

              if (purchase.status == PurchaseStatus.error) {
                await finish(
                  PremiumIapResult.failure(
                    purchase.error?.message ??
                        'Your purchase could not be completed. Please try again.',
                  ),
                );
                return;
              }

              if (purchase.status == PurchaseStatus.purchased ||
                  purchase.status == PurchaseStatus.restored) {
                final verified = _hasVerificationPayload(purchase);
                if (!verified) {
                  await finish(
                    const PremiumIapResult.failure(
                      'Purchase verification failed. Please contact support.',
                    ),
                  );
                  return;
                }

                await finish(PremiumIapResult.success(purchase: purchase));
                return;
              }

              await finish(
                const PremiumIapResult.failure('Purchase cancelled by user.'),
              );
              return;
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

      final launched = await _inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
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
    } on Exception catch (e) {
      return PremiumIapResult.failure(
        'In-app purchase failed unexpectedly: $e',
      );
    }
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
          'Do a full app restart/reinstall and test on a Play-enabled device or emulator.';
    }

    if (code.contains('billing_unavailable')) {
      return 'Google Play Billing is unavailable on this device/account.';
    }

    if (code.contains('item_unavailable')) {
      return 'This subscription product is not available for your account/region yet.';
    }

    return error.message ?? 'In-app purchase could not be started.';
  }
}
