import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/repositories/labeler_repository.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';

typedef ModerationReportSubmitter =
    Future<void> Function(ModerationCreateReportInput input, String serviceDid);

final moderationReportServiceProvider = Provider<ModerationReportService>(
  (ref) => ModerationReportService(GetIt.I<SprkRepository>()),
);

final class ModerationReportOptions {
  const ModerationReportOptions(this.services);

  final List<CompatibleModerationService> services;

  String? get defaultServiceDid => services.firstOrNull?.did;
}

final class ModerationReportService {
  const ModerationReportService(this._repository);

  final SprkRepository _repository;

  Future<ModerationReportOptions> loadOptions({
    required UModerationCreateReportSubject subject,
    required ReasonType reasonType,
    String? fallbackServiceDid,
  }) async {
    final subjectData = subject.data;
    final isBskyRecord =
        subjectData is RepoStrongRef &&
        subjectData.uri.collection.toString().startsWith('app.bsky');
    final fallbackProxyDid =
        fallbackServiceDid ??
        (isBskyRecord ? _repository.bskyModDid : _repository.modDid);
    final fallbackDid = fallbackProxyDid.split('#').first;
    final services = await _repository.labeler.getCompatibleModerationServices(
      _repository.labelerDids,
      ModerationServiceQuery.forReport(
        fallbackDid: fallbackDid,
        subject: subject,
        reasonType: reasonType.toJson(),
      ),
    );
    return ModerationReportOptions(services);
  }

  Future<void> submit({
    required UModerationCreateReportSubject subject,
    required ReasonType reasonType,
    required String serviceDid,
    String? reason,
    ModerationReportSubmitter? submitter,
  }) async {
    final input = ModerationCreateReportInput(
      subject: subject,
      reasonType: reasonType,
      reason: reason,
    );
    if (submitter != null) {
      await submitter(input, serviceDid);
      return;
    }
    await _repository.repo.createReport(input: input, serviceDid: serviceDid);
  }
}
