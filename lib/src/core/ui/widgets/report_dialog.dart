import 'dart:async';

import 'package:poptart_lex/com/atproto/moderation/create_report.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:spark/src/core/design_system/components/atoms/icons.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/moderation/moderation_report_catalog.dart';
import 'package:spark/src/core/moderation/moderation_report_service.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:spark/src/core/utils/logging/logger.dart';

class ReportDialog extends ConsumerStatefulWidget {
  const ReportDialog({
    required this.subject,
    this.fallbackServiceDid,
    super.key,
    this.onSubmit,
  });
  final UModerationCreateReportSubject subject;
  final String? fallbackServiceDid;

  final ModerationReportSubmitter? onSubmit;

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
  Future<ModerationReportOptions>? _reportOptionsFuture;
  String? _selectedServiceDid;

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
    final optionsFuture = ref
        .read(moderationReportServiceProvider)
        .loadOptions(
          subject: widget.subject,
          reasonType: reason.reasonType,
          fallbackServiceDid: widget.fallbackServiceDid,
        );
    setState(() {
      _selectedReason = reason;
      _reportOptionsFuture = optionsFuture;
      _selectedServiceDid = null;
    });
    unawaited(_selectDefaultService(optionsFuture, reason));
  }

  Future<void> _selectDefaultService(
    Future<ModerationReportOptions> optionsFuture,
    ReportReason reason,
  ) async {
    try {
      final options = await optionsFuture;
      if (!mounted || _selectedReason != reason) return;
      setState(() {
        _selectedServiceDid = options.defaultServiceDid;
      });
    } catch (error, stackTrace) {
      _logger.w(
        'Could not select a default moderation service',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _goBack() {
    setState(() {
      _selectedCategory = null;
      _selectedReason = null;
      _reportOptionsFuture = null;
      _selectedServiceDid = null;
    });
  }

  Future<void> _submitReport() async {
    if (_selectedReason == null || _selectedServiceDid == null) return;

    final l10n = AppLocalizations.of(context);
    final subject = widget.subject;
    final reason = _additionalInfoController.text.isNotEmpty
        ? _additionalInfoController.text
        : null;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(moderationReportServiceProvider)
          .submit(
            subject: subject,
            reasonType: _selectedReason!.reasonType,
            reason: reason,
            serviceDid: _selectedServiceDid!,
            submitter: widget.onSubmit,
          );
      if (mounted) {
        context.router.maybePop();
      }
    } catch (e) {
      _logger.e('Error creating report', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = l10n.errorGeneric;
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textColor =
        theme.textTheme.bodyMedium?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final isStep2 = _selectedCategory != null;
    final reasons = isStep2
        ? (reportCategoryReasons[_selectedCategory!] ?? <ReportReason>[])
        : <ReportReason>[];

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Row(
        children: [
          if (isStep2)
            IconButton(
              icon: const AppIcon(AppIconData.arrowBack),
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
            icon: const AppIcon(AppIconData.cancel),
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
        child: SingleChildScrollView(
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
                FutureBuilder<ModerationReportOptions>(
                  future: _reportOptionsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(l10n.moderationServiceLoadFailed);
                    }
                    final services = snapshot.data?.services ?? const [];
                    if (services.isEmpty) {
                      return Text(l10n.moderationNoCompatibleService);
                    }
                    return DropdownButtonFormField<String>(
                      icon: const AppIcon(AppIconData.chevronDown),
                      key: ValueKey(
                        '${_selectedReason!.value}:${_selectedServiceDid ?? ''}',
                      ),
                      initialValue: _selectedServiceDid,
                      decoration: InputDecoration(
                        labelText: l10n.moderationService,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final service in services)
                          DropdownMenuItem(
                            value: service.did,
                            child: Text(
                              service.isDefault &&
                                      service.displayName == service.did
                                  ? l10n.moderationDefaultService
                                  : service.displayName,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedServiceDid = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _additionalInfoController,
                  maxLines: 3,
                  style: theme.textTheme.bodySmall?.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: l10n.hintAdditionalDetails,
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
      ),
      actions: [
        if (isStep2 && _selectedReason != null && _selectedServiceDid != null)
          _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : AppButton(
                  label: l10n.buttonSubmit,
                  onPressed: _submitReport,
                  size: AppButtonSize.compact,
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
            AppIcon(
              AppIconData.chevronRight,
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
