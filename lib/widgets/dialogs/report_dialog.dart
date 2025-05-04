import 'package:atproto/core.dart';
import 'package:flutter/material.dart';
import 'package:atproto/atproto.dart';
import 'package:provider/provider.dart';
import 'package:sparksocial/services/mod_service.dart';
import 'package:sparksocial/services/auth_service.dart';

class ReportDialog extends StatefulWidget {
  final String postUri;
  final String postCid;
  final Function(ReportSubject subject, ModerationReasonType reasonType, String? reason, ModerationService? service)? onSubmit;

  const ReportDialog({super.key, required this.postUri, required this.postCid, this.onSubmit});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
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
    final subject = ReportSubject.strongRef(data: StrongRef(cid: widget.postCid, uri: AtUri.parse(widget.postUri)));
    final reason = _additionalInfoController.text.isNotEmpty ? _additionalInfoController.text : null;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSubmit != null) {
        // eventually this will be a ModerationService
        // by default, ModService sends it to the user's PDS
        widget.onSubmit!(subject, _selectedReason, reason, null);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        // Get AuthService from provider and create ModService directly
        final authService = Provider.of<AuthService>(context, listen: false);
        final modService = ModService(authService);

        final success = await modService.createReport(subject: subject, reasonType: _selectedReason, reason: reason);

        if (success && mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
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
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : Colors.black);

    return AlertDialog(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
      title: Text('Report', style: theme.textTheme.titleLarge?.copyWith(color: textColor)),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final reason in ModerationReasonType.values) _buildReasonTile(reason, theme, textColor),

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
                fillColor: isDark ? theme.colorScheme.surface : null,
                filled: isDark,
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
                  child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: textColor)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child:
              _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit'),
        ),
      ],
    );
  }

  Widget _buildReasonTile(ModerationReasonType reason, ThemeData theme, Color textColor) {
    final friendlyName = _reasonDescriptions[reason]?['name'] ?? reason.value;
    final description = _reasonDescriptions[reason]?['description'] ?? '';

    return RadioListTile<ModerationReasonType>(
      title: Text(
        friendlyName,
        style: theme.textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.w500, fontSize: 13),
      ),
      subtitle: Text(description, style: theme.textTheme.bodySmall?.copyWith(color: textColor.withAlpha(179), fontSize: 10)),
      value: reason,
      groupValue: _selectedReason,
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      dense: true,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedReason = value;
          });
        }
      },
    );
  }
}
