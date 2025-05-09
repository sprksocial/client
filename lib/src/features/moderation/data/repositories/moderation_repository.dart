import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';

/// Repository for handling moderation actions
abstract class ModerationRepository {
  /// Creates a report for content or an account
  /// 
  /// [subject] The subject of the report (content or account)
  /// [reasonType] The reason for the report
  /// [reason] Optional additional context about the violation
  /// [service] Optional moderation service to use
  /// 
  /// Returns true if the report was successfully created
  Future<bool> createReport({
    required ReportSubject subject,
    required ModerationReasonType reasonType,
    String? reason,
    ModerationService? service,
  });
} 