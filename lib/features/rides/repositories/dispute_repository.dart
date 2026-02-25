import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dispute_repository.g.dart';

/// Repository for filing and managing ride disputes.
class DisputeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  DisputeRepository(this._firestore, this._storage);

  /// Submits a new dispute and returns the document ID.
  Future<String> submitDispute({
    required String rideId,
    required String userId,
    required String? userEmail,
    required String disputeType,
    required String description,
    String? rideSummary,
  }) async {
    final docRef = await _firestore.collection('disputes').add({
      'rideId': rideId,
      'userId': userId,
      'userEmail': userEmail,
      'disputeType': disputeType,
      'description': description,
      'rideSummary': rideSummary,
      'attachmentUrls': <String>[],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Uploads attachment files and updates the dispute document.
  Future<List<String>> uploadAttachments({
    required String disputeId,
    required List<File> files,
  }) async {
    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.split('.').last;
      final ref = _storage
          .ref()
          .child('dispute_attachments')
          .child(disputeId)
          .child('file_$i.$ext');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    if (urls.isNotEmpty) {
      await _firestore.collection('disputes').doc(disputeId).update({
        'attachmentUrls': urls,
      });
    }

    return urls;
  }
}

@riverpod
DisputeRepository disputeRepository(Ref ref) {
  return DisputeRepository(
    FirebaseFirestore.instance,
    FirebaseStorage.instance,
  );
}
