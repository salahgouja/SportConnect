import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/auth/view_models/auth_view_model.dart';

part 'role_selection_view_model.g.dart';

/// State for the role-selection screen.
class RoleSelectionState {
  final bool isLoading;
  final bool isSuccess;
  final UserRole? selectedRole;
  final String? errorMessage;

  const RoleSelectionState({
    this.isLoading = false,
    this.isSuccess = false,
    this.selectedRole,
    this.errorMessage,
  });

  RoleSelectionState copyWith({
    bool? isLoading,
    bool? isSuccess,
    UserRole? selectedRole,
    String? errorMessage,
    bool clearError = false,
  }) =>
      RoleSelectionState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        selectedRole: selectedRole ?? this.selectedRole,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

@riverpod
class RoleSelectionViewModel extends _$RoleSelectionViewModel {
  @override
  RoleSelectionState build() => const RoleSelectionState();

  void selectRole(UserRole role) {
    state = state.copyWith(selectedRole: role, clearError: true);
  }

  /// Saves the selected role and returns the chosen role on success.
  Future<void> continueWithRole() async {
    final role = state.selectedRole;
    if (role == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final authActions = ref.read(authActionsViewModelProvider);
      final currentUser = authActions.currentUser;
      if (currentUser == null) throw StateError('User not authenticated');

      await authActions.updateUserRole(currentUser.uid, role);
      if (!ref.mounted) return;

      state = state.copyWith(isLoading: false, isSuccess: true, clearError: true);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
