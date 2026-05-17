import 'dart:typed_data';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:poptart/poptart.dart';
import 'package:spark/src/core/network/atproto/data/models/record_models.dart';

/// Interface for Repository-related API endpoints
abstract class RepoRepository {
  /// Get a record from the repository
  Future<({Record record, RepoStrongRef strongRef})> getRecord({
    required AtUri uri,
  });

  /// Edit a record in the repository
  ///
  /// [uri] The URI of the record to edit
  /// [record] The record data to edit
  Future<RepoStrongRef> editRecord({
    required AtUri uri,
    required Record record,
  });

  /// Edit a record in the repository from serialized lexicon data
  ///
  /// [uri] The URI of the record to edit
  /// [record] The serialized record data to edit
  Future<RepoStrongRef> editRecordJson({
    required AtUri uri,
    required Map<String, dynamic> record,
  });

  /// Create a record in the repository
  ///
  /// [collection] The NSID of the collection to create the record in
  /// [record] The record data to create
  /// [rkey] Optional record key
  /// [repo] Optional DID of the repo (defaults to current user's DID)
  Future<RepoStrongRef> createRecord({
    required String collection,
    required Map<String, dynamic> record,
    String? rkey,
    String? repo,
  });

  /// Delete a record from the repository
  ///
  /// [uri] The URI of the record to delete
  /// [skipBskyCrosspostCleanup] If true, skips attempt to delete crosspost
  Future<void> deleteRecord({
    required AtUri uri,
    bool skipBskyCrosspostCleanup = false,
  });

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
    required String collection,
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
    required ModerationCreateReportInput input,
    dynamic service,
  });
}
