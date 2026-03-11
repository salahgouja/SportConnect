import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'help_center_view_model.g.dart';

class HelpCenterUiState {
  const HelpCenterUiState({this.searchFieldKey = 0, this.searchQuery = ''});

  final int searchFieldKey;
  final String searchQuery;

  HelpCenterUiState copyWith({int? searchFieldKey, String? searchQuery}) {
    return HelpCenterUiState(
      searchFieldKey: searchFieldKey ?? this.searchFieldKey,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class HelpCenterUiViewModel extends _$HelpCenterUiViewModel {
  @override
  HelpCenterUiState build() => const HelpCenterUiState();

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value.trimLeft());
  }

  void clearSearch() {
    state = HelpCenterUiState(searchFieldKey: state.searchFieldKey + 1);
  }
}
