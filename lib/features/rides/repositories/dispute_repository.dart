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

  // R-18: Allowed MIME types / extensions for dispute attachments.
  static const _allowedExtensions = {'jpg', 'jpeg', 'png', 'webp', 'pdf'};
  static const _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const _maxFilesPerUpload = 5;

  /// Submits a new dispute and returns the document ID.
  Future<String> submitDispute({
    required String rideId,
    required String userId,
    required String? userEmail,
    required String disputeType,
    required String description,
    String? rideSummary,
  }) async {
    // R-16: Reject if the user already has an open dispute for this ride.
    final existing = await _firestore
        .collection(AppConstants.disputesCollection)
        .where('rideId', isEqualTo: rideId)
        .where('complainantId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'open', 'inReview'])
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw StateError(
        'You already have an open dispute for this ride. '
        'Please wait for it to be resolved before filing another.',
      );
    }

    // FIX FS-3: Write `complainantId` so it matches the Firestore security
    // rules which gate reads/writes on `complainantId == request.auth.uid`.
    // Without this field the rules always deny read/write for the filing user.
    final docRef = await _firestore
        .collection(AppConstants.disputesCollection)
        .add({
          'rideId': rideId,
          'userId': userId, // kept for backward-compat queries
          'complainantId': userId, // matches firestore.rules
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
    // R-18: Validate count, extension, and file size before uploading.
    if (files.length > _maxFilesPerUpload) {
      throw ArgumentError(
        'Cannot upload more than $_maxFilesPerUpload files at once.',
      );
    }
    for (final file in files) {
      final ext = file.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(ext)) {
        throw ArgumentError(
          'File type ".$ext" is not allowed. '
          'Allowed types: ${_allowedExtensions.join(', ')}.',
        );
      }
      final size = await file.length();
      if (size > _maxFileSizeBytes) {
        throw ArgumentError(
          'File "${file.path.split('/').last}" exceeds the 5 MB size limit '
          '(${(size / 1024 / 1024).toStringAsFixed(1)} MB).',
        );
      }
    }

    final urls = <String>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.split('.').last.toLowerCase();
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
      // Use arrayUnion so concurrent or batched uploads accumulate correctly
      // instead of overwriting the entire array each time.
      await _firestore
          .collection(AppConstants.disputesCollection)
          .doc(disputeId)
          .update({'attachmentUrls': FieldValue.arrayUnion(urls)});
    }

    return urls;
  }

  // ─── R-19: Admin / support resolution flow ────────────────────────────────

  /// Returns a single dispute by ID, or null if not found.
  Future<Map<String, dynamic>?> getDisputeById(String disputeId) async {
    final doc = await _firestore
        .collection(AppConstants.disputesCollection)
        .doc(disputeId)
        .get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  /// Returns all disputes filed by [userId], most-recent-first.
  Future<List<Map<String, dynamic>>> getDisputesByUser(String userId) async {
    final snap = await _firestore
        .collection(AppConstants.disputesCollection)
        .where('complainantId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Returns all disputes for a given ride.
  Future<List<Map<String, dynamic>>> getDisputesByRide(String rideId) async {
    final snap = await _firestore
        .collection(AppConstants.disputesCollection)
        .where('rideId', isEqualTo: rideId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Updates the dispute status (e.g. 'inReview', 'resolved', 'closed').
  Future<void> updateDisputeStatus({
    required String disputeId,
    required String status,
    String? resolution,
    String? resolvedByUid,
  }) async {
    await _firestore
        .collection(AppConstants.disputesCollection)
        .doc(disputeId)
        .update({
          'status': status,
          if (resolution != null) 'resolution': resolution,
          if (resolvedByUid != null) 'resolvedByUid': resolvedByUid,
          'updatedAt': DateTime.now(),
        });
  }

  /// Resolves a dispute — shorthand for updateDisputeStatus with 'resolved'.
  Future<void> resolveDispute({
    required String disputeId,
    required String resolution,
    required String resolvedByUid,
  }) =>
      updateDisputeStatus(
        disputeId: disputeId,
        status: 'resolved',
        resolution: resolution,
        resolvedByUid: resolvedByUid,
      );
}
