import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/admin/defs.dart';
import 'package:poptart_lex/com/atproto/label/defs.dart';
import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:poptart_lex/com/atproto/moderation/defs.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';

final moderationAppealServiceProvider = Provider<ModerationAppealService>(
  (ref) => ModerationAppealService(GetIt.I<SprkRepository>()),
);

final class ModerationAppealService {
  const ModerationAppealService(this._repository);

  final SprkRepository _repository;

  static bool canAppeal(Label label) {
    return label.src != _subjectDid(label) &&
        label.src.startsWith('did:') &&
        _reportSubject(label) != null;
  }

  Future<void> appeal(Label label, {required String reason}) async {
    final subject = _reportSubject(label);
    if (subject == null) return;

    await _repository.repo.createReport(
      input: ModerationCreateReportInput(
        subject: subject,
        reasonType: const ReasonType.knownValue(
          data: KnownReasonType.comAtprotoModerationDefsReasonAppeal,
        ),
        reason: reason,
      ),
      serviceDid: label.src,
    );
  }
}

UModerationCreateReportSubject? _reportSubject(Label label) {
  AtUri? uri;
  try {
    uri = AtUri.parse(label.uri);
  } catch (_) {
    return null;
  }
  if (uri.pathname.isEmpty) {
    return UModerationCreateReportSubject.repoRef(
      data: RepoRef(did: uri.hostname),
    );
  }
  if (label.cid?.isNotEmpty ?? false) {
    return UModerationCreateReportSubject.repoStrongRef(
      data: RepoStrongRef(uri: uri, cid: label.cid!),
    );
  }
  return null;
}

String _subjectDid(Label label) {
  try {
    return AtUri.parse(label.uri).hostname;
  } catch (_) {
    return label.uri;
  }
}
