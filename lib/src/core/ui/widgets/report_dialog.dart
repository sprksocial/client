import 'package:atproto/com_atproto_moderation_createreport.dart';
import 'package:atproto/com_atproto_moderation_defs.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:bluesky/com_atproto_repo_strongref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

enum ReportCategory {
  violence('Violence'),
  sexual('Sexual Content'),
  childSafety('Child Safety'),
  harassment('Harassment'),
  misleading('Misleading'),
  ruleViolations('Rule Violations'),
  selfHarm('Self-Harm'),
  other('Other')
  ;

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
}

class ReportDialog extends ConsumerStatefulWidget {
  const ReportDialog({
    required this.postUri,
    required this.postCid,
    super.key,
    this.onSubmit,
  });
  final String postUri;
  final String postCid;

  /// Callback for report submission. Uses [ReasonType] directly to support
  /// known & unknown reason types.
  final Function(
    UModerationCreateReportSubject subject,
    ReasonType reasonType,
    String? reason,
  )?
  onSubmit;

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final SparkLogger _logger = GetIt.instance<LogService>().getLogger(
    'ReportDialog',
  );
  ReportCategory? _selectedCategory;
  ReportReason? _selectedReason;
  final TextEditingController _additionalInfoController =
      TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Map categories to their reasons
  static final Map<ReportCategory, List<ReportReason>> _categoryReasons = {
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
        knownType:
            KnownReasonType.toolsOzoneReportDefsReasonViolenceTrafficking,
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
        knownType:
            KnownReasonType.toolsOzoneReportDefsReasonHarassmentHateSpeech,
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
        knownType:
            KnownReasonType.toolsOzoneReportDefsReasonMisleadingElections,
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
        knownType:
            KnownReasonType.toolsOzoneReportDefsReasonRuleProhibitedSales,
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

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _selectCategory(ReportCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedReason = null;
    });
  }

  void _selectReason(ReportReason reason) {
    setState(() {
      _selectedReason = reason;
    });
  }

  void _goBack() {
    setState(() {
      _selectedCategory = null;
      _selectedReason = null;
    });
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null) return;

    final subject = UModerationCreateReportSubject.repoStrongRef(
      data: RepoStrongRef(
        cid: widget.postCid,
        uri: AtUri.parse(widget.postUri),
      ),
    );
    final reason = _additionalInfoController.text.isNotEmpty
        ? _additionalInfoController.text
        : null;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      // Build the ReasonType: use known type if available, otherwise unknown
      // with the raw value
      final reasonType = _selectedReason!.knownType != null
          ? ReasonType.knownValue(data: _selectedReason!.knownType!)
          : ReasonType.unknown(data: _selectedReason!.value);

      if (widget.onSubmit != null) {
        // Use the callback if provided - now passing ReasonType directly
        widget.onSubmit!(subject, reasonType, reason);
        if (mounted) {
          context.router.maybePop();
        }
      } else {
        // Get the repository directly and create the report
        final repoRepository = GetIt.instance<SprkRepository>().repo;
        _logger.d('Creating report with reason: ${_selectedReason!.value}');

        final success = await repoRepository.createReport(
          input: ModerationCreateReportInput(
            subject: subject,
            reasonType: reasonType,
            reason: reason,
          ),
        );

        if (success && mounted) {
          context.router.maybePop();
        }
      }
    } catch (e) {
      _logger.e('Error creating report', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final isStep2 = _selectedCategory != null;
    final reasons = isStep2
        ? (_categoryReasons[_selectedCategory!] ?? <ReportReason>[])
        : <ReportReason>[];

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Row(
        children: [
          if (isStep2)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              color: textColor,
            ),
          if (isStep2) const SizedBox(width: 8),
          Expanded(
            child: Text(
              isStep2 ? _selectedCategory!.displayName : 'Report',
              style: theme.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSubmitting ? null : () => context.router.maybePop(),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: textColor,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isStep2)
              // Step 1: Category selection
              ...ReportCategory.values.map(
                (category) => _CategoryTile(
                  category: category,
                  selectedCategory: _selectedCategory,
                  onTap: () => _selectCategory(category),
                ),
              )
            else
              // Step 2: Reason selection
              ...reasons.map(
                (reason) => _ReasonTile(
                  reason: reason,
                  selectedReason: _selectedReason,
                  onChanged: (value) {
                    if (value != null) {
                      _selectReason(value);
                    }
                  },
                ),
              ),

            if (isStep2 && _selectedReason != null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _additionalInfoController,
                maxLines: 3,
                style: theme.textTheme.bodySmall?.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: const OutlineInputBorder(),
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                  fillColor: theme.colorScheme.surface,
                  filled: true,
                ),
              ),
            ],

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withAlpha(25),
                    border: Border.all(color: theme.colorScheme.error),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (isStep2 && _selectedReason != null)
          _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : LongButton(
                  label: 'Submit',
                  onPressed: _submitReport,
                ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selectedCategory,
    required this.onTap,
  });
  final ReportCategory category;
  final ReportCategory? selectedCategory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final isSelected = selectedCategory == category;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                category.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor.withAlpha(179),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selectedReason,
    required this.onChanged,
  });
  final ReportReason reason;
  final ReportReason? selectedReason;
  final ValueChanged<ReportReason?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);

    return RadioListTile<ReportReason>(
      title: Text(
        reason.displayName,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      subtitle: reason.description != null
          ? Text(
              reason.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withAlpha(179),
                fontSize: 10,
              ),
            )
          : null,
      value: reason,
      // ignore: deprecated_member_use
      groupValue: selectedReason,
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return theme.colorScheme.primary;
        }
        return theme.colorScheme.onSurface.withAlpha(150);
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      // ignore: deprecated_member_use
      onChanged: onChanged,
    );
  }
}
