import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/interfaces/repositories/i_dispute_repository.dart';

/// Repository for filing and managing ride disputes.
class DisputeRepository implements IDisputeRepository {
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
    final docRef = await _firestore
        .collection(AppConstants.disputesCollection)
        .add({
          'rideId': rideId,
          'userId': userId,
          'userEmail': userEmail,
          'disputeType': disputeType,
          'description': description,
          'rideSummary': rideSummary,
          'attachmentUrls': <String>[],
          'status': 'pending',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
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
      await _firestore
          .collection(AppConstants.disputesCollection)
          .doc(disputeId)
          .update({'attachmentUrls': urls});
    }

    return urls;
  }
}
