// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for submitting reviews

@ProviderFor(ReviewFormViewModel)
final reviewFormViewModelProvider = ReviewFormViewModelProvider._();

/// ViewModel for submitting reviews
final class ReviewFormViewModelProvider
    extends $NotifierProvider<ReviewFormViewModel, ReviewFormState> {
  /// ViewModel for submitting reviews
  ReviewFormViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewFormViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewFormViewModelHash();

  @$internal
  @override
  ReviewFormViewModel create() => ReviewFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewFormState>(value),
    );
  }
}

String _$reviewFormViewModelHash() =>
    r'799320189043924c3ffe602a9fdaee00f660d948';

/// ViewModel for submitting reviews

abstract class _$ReviewFormViewModel extends $Notifier<ReviewFormState> {
  ReviewFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReviewFormState, ReviewFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewFormState, ReviewFormState>,
              ReviewFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// ViewModel for viewing reviews list

@ProviderFor(ReviewsListViewModel)
final reviewsListViewModelProvider = ReviewsListViewModelFamily._();

/// ViewModel for viewing reviews list
final class ReviewsListViewModelProvider
    extends $AsyncNotifierProvider<ReviewsListViewModel, ReviewsListState> {
  /// ViewModel for viewing reviews list
  ReviewsListViewModelProvider._({
    required ReviewsListViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'reviewsListViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewsListViewModelHash();

  @override
  String toString() {
    return r'reviewsListViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReviewsListViewModel create() => ReviewsListViewModel();

  @override
  bool operator ==(Object other) {
    return other is ReviewsListViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewsListViewModelHash() =>
    r'cc1c4bbc41b3e61dee3a9eb595d22328f17f9750';

/// ViewModel for viewing reviews list

final class ReviewsListViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ReviewsListViewModel,
          AsyncValue<ReviewsListState>,
          ReviewsListState,
          FutureOr<ReviewsListState>,
          String
        > {
  ReviewsListViewModelFamily._()
    : super(
        retry: null,
        name: r'reviewsListViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ViewModel for viewing reviews list

  ReviewsListViewModelProvider call(String userId) =>
      ReviewsListViewModelProvider._(argument: userId, from: this);

  @override
  String toString() => r'reviewsListViewModelProvider';
}

/// ViewModel for viewing reviews list

abstract class _$ReviewsListViewModel extends $AsyncNotifier<ReviewsListState> {
  late final _$args = ref.$arg as String;
  String get userId => _$args;

  FutureOr<ReviewsListState> build(String userId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ReviewsListState>, ReviewsListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReviewsListState>, ReviewsListState>,
              AsyncValue<ReviewsListState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// ViewModel for responding to a review

@ProviderFor(ReviewResponseViewModel)
final reviewResponseViewModelProvider = ReviewResponseViewModelProvider._();

/// ViewModel for responding to a review
final class ReviewResponseViewModelProvider
    extends $NotifierProvider<ReviewResponseViewModel, AsyncValue<void>> {
  /// ViewModel for responding to a review
  ReviewResponseViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewResponseViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewResponseViewModelHash();

  @$internal
  @override
  ReviewResponseViewModel create() => ReviewResponseViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reviewResponseViewModelHash() =>
    r'b6462eb98cb2d5bf763e864d52833d5a2e52f3c0';

/// ViewModel for responding to a review

abstract class _$ReviewResponseViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
