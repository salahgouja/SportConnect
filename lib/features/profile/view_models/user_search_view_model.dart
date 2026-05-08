import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/models/user/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

part 'user_search_view_model.g.dart';

/// Search results provider — accepts the query as a family parameter
/// so ephemeral search state stays local to the widget.
@riverpod
Future<List<UserModel>> searchResults(Ref ref, String query) async {
  final trimmedQuery = query.trim();

  if (trimmedQuery.length < 2) return [];

  final vm = ref.read(profileActionsViewModelProvider.notifier);
  return vm.searchUsers(query: trimmedQuery);
}

class UserSearchUiState {
  const UserSearchUiState({this.query = '', this.searchFieldKey = 0});

  final String query;
  final int searchFieldKey;

  UserSearchUiState copyWith({String? query, int? searchFieldKey}) {
    return UserSearchUiState(
      query: query ?? this.query,
      searchFieldKey: searchFieldKey ?? this.searchFieldKey,
    );
  }
}

@riverpod
class UserSearchUiViewModel extends _$UserSearchUiViewModel {
  @override
  UserSearchUiState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const UserSearchUiState();
  }

  Timer? _debounceTimer;

  void scheduleQuery(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final normalizedQuery = query.trim();
      if (normalizedQuery == state.query) {
        return;
      }
      state = state.copyWith(query: normalizedQuery);
    });
  }

  void clear() {
    _debounceTimer?.cancel();
    state = UserSearchUiState(searchFieldKey: state.searchFieldKey + 1);
  }

  void applySuggestion(String query) {
    _debounceTimer?.cancel();
    state = UserSearchUiState(
      query: query.trim(),
      searchFieldKey: state.searchFieldKey + 1,
    );
  }
}
