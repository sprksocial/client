import 'package:atproto/atproto.dart';
import 'package:atproto/core.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:sparksocial/src/core/network/atproto/data/repositories/sprk_repository.dart';
import 'package:sparksocial/src/core/utils/logging/log_service.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String postUri;
  final String postCid;
  final Function(ReportSubject subject, ModerationReasonType reasonType, String? reason, ModerationService? service)? onSubmit;

  const ReportDialog({
    super.key, 
    required this.postUri, 
    required this.postCid, 
    this.onSubmit
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  final _logger = GetIt.instance<LogService>().getLogger('ReportDialog');
  ModerationReasonType _selectedReason = ModerationReasonType.spam;
  final TextEditingController _additionalInfoController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  // Map of user-friendly names and descriptions for each reason type
  final Map<ModerationReasonType, Map<String, String>> _reasonDescriptions = {
    ModerationReasonType.spam: {'name': 'Spam', 'description': 'Unwanted or repetitive content'},
    ModerationReasonType.violation: {'name': 'Terms Violation', 'description': 'Violates platform terms'},
    ModerationReasonType.misleading: {'name': 'Misleading Info', 'description': 'False or deceptive content'},
    ModerationReasonType.sexual: {'name': 'Sexual Content', 'description': 'Inappropriate explicit material'},
    ModerationReasonType.rude: {'name': 'Harassment', 'description': 'Abusive or threatening behavior'},
    ModerationReasonType.other: {'name': 'Other', 'description': 'Other issues not listed above'},
  };

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    final subject = ReportSubject.strongRef(
      data: StrongRef(cid: widget.postCid, uri: AtUri.parse(widget.postUri))
    );
    final reason = _additionalInfoController.text.isNotEmpty 
        ? _additionalInfoController.text 
        : null;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSubmit != null) {
        // Use the callback if provided
        widget.onSubmit!(subject, _selectedReason, reason, null);
        if (mounted) {
          context.router.maybePop();
        }
      } else {
        // Get the repository directly and create the report
        final repoRepository = GetIt.instance<SprkRepository>().repo;
        _logger.d('Creating report with reason: ${_selectedReason.value}');
        
        final success = await repoRepository.createReport(
          subject: subject,
          reasonType: _selectedReason,
          reason: reason,
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
    final textColor = theme.textTheme.bodyMedium?.color ?? (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text('Report', style: theme.textTheme.titleLarge?.copyWith(color: textColor)),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final reason in ModerationReasonType.values) 
              _ReasonTile(
                reason: reason,
                selectedReason: _selectedReason,
                reasonDescription: _reasonDescriptions[reason] ?? {'name': reason.value, 'description': ''},
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedReason = value;
                    });
                  }
                },
              ),

            const SizedBox(height: 8),
            TextField(
              controller: _additionalInfoController,
              maxLines: 3,
              style: theme.textTheme.bodySmall?.copyWith(color: textColor),
              decoration: InputDecoration(
                hintText: 'Additional details (optional)',
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: const OutlineInputBorder(),
                hintStyle: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                fillColor: theme.colorScheme.surface,
                filled: true,
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withAlpha(25),
                    border: Border.all(color: theme.colorScheme.error),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _errorMessage!, 
                    style: TextStyle(color: theme.colorScheme.error, fontSize: 12)
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => context.router.maybePop(),
          child: Text('Cancel', style: TextStyle(color: textColor)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final ModerationReasonType reason;
  final ModerationReasonType selectedReason;
  final Map<String, String> reasonDescription;
  final ValueChanged<ModerationReasonType?> onChanged;

  const _ReasonTile({
    required this.reason,
    required this.selectedReason,
    required this.reasonDescription,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? (theme.brightness == Brightness.dark ? Colors.white : Colors.black);
    final friendlyName = reasonDescription['name'] ?? reason.value;
    final description = reasonDescription['description'] ?? '';

    return RadioListTile<ModerationReasonType>(
      title: Text(
        friendlyName,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor, 
          fontWeight: FontWeight.w500, 
          fontSize: 13
        ),
      ),
      subtitle: Text(
        description, 
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor.withAlpha(179), 
          fontSize: 10
        )
      ),
      value: reason,
      groupValue: selectedReason,
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      onChanged: onChanged,
    );
  }
} 