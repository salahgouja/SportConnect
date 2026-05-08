import 'package:flutter/foundation.dart';
import 'package:sport_connect/core/models/user/models.dart';

/// Result of a social sign-in operation (Google, Apple, etc.)
///
/// Contains the [user] model from Firestore and an [isNewUser] flag
/// indicating whether this was a first-time sign-in (new account).
@immutable
class SocialSignInResult {
  const SocialSignInResult({this.user, this.isNewUser = false});
  final UserModel? user;
  final bool isNewUser;
}
