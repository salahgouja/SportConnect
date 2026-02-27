import 'dart:io';

/// Support and reporting operations repository interface.
abstract class ISupportRepository {
  /// Submits a user or ride report and returns the new document ID.
  Future<String> submitReport({
    required String reporterId,
    required String reporterEmail,
    required String type,
    required String severity,
    required String description,
    String? reportedUserId,
    String? rideId,
    List<File> attachments,
  });

  /// Submits a support ticket and returns the new document ID.
  Future<String> submitSupportTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String category,
    required String subject,
    required String message,
    List<File> attachments,
  });
}
