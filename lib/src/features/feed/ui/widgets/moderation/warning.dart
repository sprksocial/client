import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/upload/data/models/content_warning_style.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/moderation/blurred_content.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/moderation/warning_message.dart';

class Warning extends StatefulWidget {
  final Widget child;
  final String labelerDid;
  final String labelValue;
  final String? warningMessage;
  final String blurType;
  final String severity;

  const Warning({
    super.key,
    required this.child,
    required this.labelerDid,
    required this.labelValue,
    this.warningMessage,
    this.blurType = 'content',
    this.severity = 'alert',
  });

  @override
  State<Warning> createState() => _WarningState();
}

class _WarningState extends State<Warning> {
  bool _showWarning = true;
  final _logger = GetIt.instance<LogService>().getLogger('WarnBuilder');

  @override
  Widget build(BuildContext context) {
    if (!_showWarning) {
      return widget.child;
    }

    _logger.d('Showing warning for content: ${widget.labelValue} with severity: ${widget.severity}');

    final style = ContentWarningStyle.fromSeverity(widget.severity);

    return Stack(
      children: [
        BlurredContent(blurType: widget.blurType, child: widget.child),

        WarningMessage(
          style: style,
          labelValue: widget.labelValue,
          warningMessage: widget.warningMessage,
          onShowContent: () {
            _logger.i('User chose to show content marked as: ${widget.labelValue}');
            setState(() {
              _showWarning = false;
            });
          },
        ),
      ],
    );
  }
}
