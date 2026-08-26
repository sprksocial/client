import 'package:poptart_lex/com/atproto/moderation/defs.dart';

enum ReportCategory {
  violence('Violence'),
  sexual('Sexual Content'),
  childSafety('Child Safety'),
  harassment('Harassment'),
  misleading('Misleading'),
  ruleViolations('Rule Violations'),
  selfHarm('Self-Harm'),
  other('Other');

  const ReportCategory(this.displayName);
  final String displayName;
}

class ReportReason {
  final String value;
  final String displayName;
  final String? description;
  final KnownReasonType? knownType;

  const ReportReason({
    required this.value,
    required this.displayName,
    this.description,
    this.knownType,
  });

  ReasonType get reasonType => knownType != null
      ? ReasonType.knownValue(data: knownType!)
      : ReasonType.unknown(data: value);
}

final Map<ReportCategory, List<ReportReason>> reportCategoryReasons = {
  ReportCategory.violence: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceAnimal',
      displayName: 'Animal Abuse',
      description: 'Content depicting harm to animals',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonViolenceAnimal,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceThreats',
      displayName: 'Threats',
      description: 'Threats of violence',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonViolenceThreats,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceGraphicContent',
      displayName: 'Graphic Content',
      description: 'Graphic or violent imagery',
      knownType:
          KnownReasonType.toolsOzoneReportDefsReasonViolenceGraphicContent,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceGlorification',
      displayName: 'Glorification of Violence',
      description: 'Content that glorifies violence',
      knownType:
          KnownReasonType.toolsOzoneReportDefsReasonViolenceGlorification,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceExtremistContent',
      displayName: 'Extremist Content',
      description: 'Content promoting extremist ideologies',
      knownType:
          KnownReasonType.toolsOzoneReportDefsReasonViolenceExtremistContent,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceTrafficking',
      displayName: 'Trafficking',
      description: 'Content related to human trafficking',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonViolenceTrafficking,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonViolenceOther',
      displayName: 'Other Violence',
      description: 'Other violent content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonViolenceOther,
    ),
  ],
  ReportCategory.sexual: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualAbuseContent',
      displayName: 'Abuse Content',
      description: 'Sexual abuse content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualAbuseContent,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualNCII',
      displayName: 'Non-Consensual Intimate Images',
      description: 'Sharing intimate images without consent',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualNCII,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualDeepfake',
      displayName: 'Deepfake',
      description: 'AI-generated sexual content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualDeepfake,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualAnimal',
      displayName: 'Animal Sexual Content',
      description: 'Sexual content involving animals',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualAnimal,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualUnlabeled',
      displayName: 'Unlabeled Sexual Content',
      description: 'Sexual content without proper warnings',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualUnlabeled,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSexualOther',
      displayName: 'Other Sexual Content',
      description: 'Other sexual content violations',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSexualOther,
    ),
  ],
  ReportCategory.childSafety: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonChildSafetyCSAM',
      displayName: 'CSAM',
      description: 'Child sexual abuse material',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonChildSafetyCSAM,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonChildSafetyGroom',
      displayName: 'Grooming',
      description: 'Grooming behavior targeting minors',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonChildSafetyGroom,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonChildSafetyPrivacy',
      displayName: 'Privacy Violation',
      description: 'Sharing private information about minors',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonChildSafetyPrivacy,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonChildSafetyHarassment',
      displayName: 'Harassment',
      description: 'Harassment targeting minors',
      knownType:
          KnownReasonType.toolsOzoneReportDefsReasonChildSafetyHarassment,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonChildSafetyOther',
      displayName: 'Other Child Safety',
      description: 'Other child safety concerns',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonChildSafetyOther,
    ),
  ],
  ReportCategory.harassment: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonHarassmentTroll',
      displayName: 'Trolling',
      description: 'Trolling or disruptive behavior',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonHarassmentTroll,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonHarassmentTargeted',
      displayName: 'Targeted Harassment',
      description: 'Targeted harassment or bullying',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonHarassmentTargeted,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonHarassmentHateSpeech',
      displayName: 'Hate Speech',
      description: 'Hate speech or discriminatory content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonHarassmentHateSpeech,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonHarassmentDoxxing',
      displayName: 'Doxxing',
      description: 'Sharing private information without consent',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonHarassmentDoxxing,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonHarassmentOther',
      displayName: 'Other Harassment',
      description: 'Other harassment violations',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonHarassmentOther,
    ),
  ],
  ReportCategory.misleading: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingBot',
      displayName: 'Bot Account',
      description: 'Automated or bot account',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonMisleadingBot,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingImpersonation',
      displayName: 'Impersonation',
      description: 'Impersonating another person or entity',
      knownType:
          KnownReasonType.toolsOzoneReportDefsReasonMisleadingImpersonation,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingSpam',
      displayName: 'Spam',
      description: 'Spam or repetitive content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonMisleadingSpam,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingScam',
      displayName: 'Scam',
      description: 'Fraudulent or scam content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonMisleadingScam,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingElections',
      displayName: 'Election Misinformation',
      description: 'False information about elections',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonMisleadingElections,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonMisleadingOther',
      displayName: 'Other Misleading',
      description: 'Other misleading content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonMisleadingOther,
    ),
  ],
  ReportCategory.ruleViolations: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonRuleSiteSecurity',
      displayName: 'Site Security',
      description: 'Violation of site security rules',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonRuleSiteSecurity,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonRuleProhibitedSales',
      displayName: 'Prohibited Sales',
      description: 'Prohibited goods or services',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonRuleProhibitedSales,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonRuleBanEvasion',
      displayName: 'Ban Evasion',
      description: 'Attempting to evade a ban',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonRuleBanEvasion,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonRuleOther',
      displayName: 'Other Rule Violation',
      description: 'Other rule violations',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonRuleOther,
    ),
  ],
  ReportCategory.selfHarm: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSelfHarmContent',
      displayName: 'Self-Harm Content',
      description: 'Content promoting self-harm',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSelfHarmContent,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSelfHarmED',
      displayName: 'Eating Disorder',
      description: 'Content promoting eating disorders',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSelfHarmED,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSelfHarmStunts',
      displayName: 'Dangerous Stunts',
      description: 'Content showing dangerous stunts',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSelfHarmStunts,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSelfHarmSubstances',
      displayName: 'Substance Abuse',
      description: 'Content promoting substance abuse',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSelfHarmSubstances,
    ),
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonSelfHarmOther',
      displayName: 'Other Self-Harm',
      description: 'Other self-harm related content',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonSelfHarmOther,
    ),
  ],
  ReportCategory.other: [
    const ReportReason(
      value: 'tools.ozone.report.defs#reasonOther',
      displayName: 'Other',
      description: 'Other issues not listed above',
      knownType: KnownReasonType.toolsOzoneReportDefsReasonOther,
    ),
  ],
};
