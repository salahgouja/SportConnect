// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search results provider — accepts the query as a family parameter
/// so ephemeral search state stays local to the widget.

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsFamily._();

/// Search results provider — accepts the query as a family parameter
/// so ephemeral search state stays local to the widget.

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserModel>>,
          List<UserModel>,
          FutureOr<List<UserModel>>
        >
    with $FutureModifier<List<UserModel>>, $FutureProvider<List<UserModel>> {
  /// Search results provider — accepts the query as a family parameter
  /// so ephemeral search state stays local to the widget.
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<UserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'8f752371f5f36bf9f38902cfdf79506c2307f908';

/// Search results provider — accepts the query as a family parameter
/// so ephemeral search state stays local to the widget.

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<UserModel>>, String> {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Search results provider — accepts the query as a family parameter
  /// so ephemeral search state stays local to the widget.

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}
