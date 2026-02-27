import 'dart:io';

/// Dispute operations repository interface.
abstract class IDisputeRepository {
  /// Submits a new dispute and returns the new document ID.
  Future<String> submitDispute({
    required String rideId,
    required String userId,
    required String? userEmail,
    required String disputeType,
    required String description,
    String? rideSummary,
  });

  /// Uploads attachment files for an existing dispute and returns their URLs.
  Future<List<String>> uploadAttachments({
    required String disputeId,
    required List<File> files,
  });
}
