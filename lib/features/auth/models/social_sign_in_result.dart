import 'package:sport_connect/features/auth/models/models.dart';

/// Result of a social sign-in operation (Google, Apple, etc.)
///
/// Contains the [user] model from Firestore and an [isNewUser] flag
/// indicating whether this was a first-time sign-in (new account).
class SocialSignInResult {
  final UserModel? user;
  final bool isNewUser;

  SocialSignInResult({this.user, this.isNewUser = false});
}
