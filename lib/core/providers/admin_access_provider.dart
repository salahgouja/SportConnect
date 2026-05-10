import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminAccessProvider = FutureProvider<bool>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final token = await user.getIdTokenResult();
  final claims = token.claims ?? const <String, dynamic>{};

  return claims['admin'] == true ||
      claims['support'] == true ||
      claims['refunds'] == true ||
      claims['role'] == 'admin' ||
      claims['role'] == 'support';
});
