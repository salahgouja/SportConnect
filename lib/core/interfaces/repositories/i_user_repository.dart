import 'package:sport_connect/features/auth/models/models.dart';

/// User data repository interface
abstract class IUserRepository {
  // User Data Operations
  Future<UserModel?> getUserById(String userId);
  Future<List<UserModel>> searchUsers({
    String? query,
    UserRole? role,
    int? limit,
  });

  Future<void> updateUser(UserModel user);
  Future<void> updateUserField(String userId, String field, dynamic value);

  // Online Status
  Future<void> updateOnlineStatus(String userId, bool isOnline);
  Stream<bool> getUserOnlineStatus(String userId);
}
