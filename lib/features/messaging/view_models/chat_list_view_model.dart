import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

part 'chat_list_view_model.g.dart';

class ChatListUiState {
  const ChatListUiState({this.searchQuery = ''});

  final String searchQuery;

  ChatListUiState copyWith({String? searchQuery}) {
    return ChatListUiState(searchQuery: searchQuery ?? this.searchQuery);
  }
}

@riverpod
class ChatListUiViewModel extends _$ChatListUiViewModel {
  @override
  ChatListUiState build() => const ChatListUiState();

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value.trim().toLowerCase());
  }
}

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

  NewChatSearchState copyWith({
    int? searchFieldKey,
    String? searchQuery,
    List<UserModel>? searchResults,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NewChatSearchState(
      searchFieldKey: searchFieldKey ?? this.searchFieldKey,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

@riverpod
class NewChatSearchViewModel extends _$NewChatSearchViewModel {
  @override
  NewChatSearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const NewChatSearchState();
  }

  Timer? _debounceTimer;

  void scheduleSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query);
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = NewChatSearchState(searchFieldKey: state.searchFieldKey + 1);
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty || query.length < 2) {
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
      final profileActions = ref.read(profileActionsViewModelProvider);
      final results = await profileActions.searchUsers(query: query);
      if (!ref.mounted) return;
      state = state.copyWith(searchResults: results, isLoading: false);
    } catch (_) {
      if (!ref.mounted) return;
      state = state.copyWith(error: 'Failed to search users', isLoading: false);
    }
  }
}
