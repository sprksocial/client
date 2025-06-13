import 'dart:typed_data';
import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';

/// Interface for Repository-related API endpoints
abstract class RepoRepository {
  /// Get a record from the repository
  Future<({Record record, StrongRef strongRef})> getRecord({required AtUri uri});

  /// Edit a record in the repository
  ///
  /// [uri] The URI of the record to edit
  /// [record] The record data to edit
  Future<StrongRef> editRecord({required AtUri uri, required Record record});

  /// Create a record in the repository
  ///
  /// [collection] The NSID of the collection to create the record in
  /// [record] The record data to create
  Future<StrongRef> createRecord({required NSID collection, required Map<String, dynamic> record, String? rkey});

  /// Delete a record from the repository
  ///
  /// [uri] The URI of the record to delete
  Future<void> deleteRecord({required AtUri uri});

  /// Upload a blob to the repository
  ///
  /// [data] The blob data to upload
  Future<Blob> uploadBlob(Uint8List data);

  /// List records in a collection
  ///
  /// [repo] The DID of the repo to list records from
  /// [collection] The NSID of the collection to list records from
  Future<List<Record>> listRecords({
    required String repo,
    required NSID collection,
    String? cursor,
    int? limit,
    bool? reverse,
  });

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
