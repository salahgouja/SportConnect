import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

part 'chat_list_view_model.g.dart';

// ── ChatListUiState ───────────────────────────────────────────────────────────

/// Holds the search query typed in the chat list search bar.
/// Kept as a plain class — too simple to justify @freezed overhead.
class ChatListUiState {
  const ChatListUiState({this.searchQuery = ''});

  final String searchQuery;

  ChatListUiState copyWith({String? searchQuery}) =>
      ChatListUiState(searchQuery: searchQuery ?? this.searchQuery);
}

@riverpod
class ChatListUiViewModel extends _$ChatListUiViewModel {
  @override
  ChatListUiState build() => const ChatListUiState();

  void setSearchQuery(String value) =>
      state = state.copyWith(searchQuery: value.trim().toLowerCase());
}

// ── NewChatSearchState ────────────────────────────────────────────────────────

class NewChatSearchState {
  const NewChatSearchState({
    this.searchFieldKey = 0,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  final int searchFieldKey;
  final String searchQuery;
  final List<UserModel> searchResults;
  final bool isLoading;
  final String? error;

  // FIX: `clearError` named parameter is the pragmatic solution for clearing
  // a nullable field without a sentinel `_unset` object or @freezed generation.
  // The alternative would be @freezed, but adds codegen overhead for this
  // small state class.
  NewChatSearchState copyWith({
    int? searchFieldKey,
    String? searchQuery,
    List<UserModel>? searchResults,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => NewChatSearchState(
    searchFieldKey: searchFieldKey ?? this.searchFieldKey,
    searchQuery: searchQuery ?? this.searchQuery,
    searchResults: searchResults ?? this.searchResults,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

// ── NewChatSearchViewModel ────────────────────────────────────────────────────

@riverpod
class NewChatSearchViewModel extends _$NewChatSearchViewModel {
  // FIX: Field declared before build() — conventional placement so the field
  // is visible before the methods that reference it.
  Timer? _debounceTimer;

  @override
  NewChatSearchState build() {
    // Timer is cancelled when the provider is disposed (e.g. on navigation pop).
    ref.onDispose(() => _debounceTimer?.cancel());
    return const NewChatSearchState();
  }

  /// Schedules a search after 400 ms of inactivity.
  /// Cancels any pending search if called again before the delay fires.
  void scheduleSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _performSearch(query),
    );
  }

  /// Clears search state and forces a widget key change to reset the
  /// TextField (so its internal text value resets without a controller).
  void clearSearch() {
    _debounceTimer?.cancel();
    // Construct fresh state (not copyWith) to reset ALL fields including query
    // and results, not just the key.
    state = NewChatSearchState(searchFieldKey: state.searchFieldKey + 1);
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      state = state.copyWith(
        searchResults: const [],
        searchQuery: query,
        isLoading: false,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      clearError: true,
    );

    try {
      final results = await ref
          .read(profileActionsViewModelProvider)
          .searchUsers(query: query);
      if (!ref.mounted) return;
      state = state.copyWith(searchResults: results, isLoading: false);
    } on Exception {
      if (!ref.mounted) return;
      state = state.copyWith(
        error: 'Failed to search users',
        isLoading: false,
      );
    }
  }
}
