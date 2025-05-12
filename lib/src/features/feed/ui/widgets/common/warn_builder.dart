import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:sparksocial/src/core/utils/logging/log_service.dart';
import 'package:sparksocial/src/features/camera/data/models/content_warning_style.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/common/blurred_content.dart';
import 'package:sparksocial/src/features/feed/ui/widgets/common/warning_overlay.dart';

class WarnBuilder extends StatefulWidget {
  final Widget child;
  final String labelerDid;
  final String labelValue;
  final String? warningMessage;
  final String blurType;
  final String severity;

  const WarnBuilder({
    super.key, 
    required this.child, 
    required this.labelerDid, 
    required this.labelValue,
    this.warningMessage,
    this.blurType = 'content',
    this.severity = 'alert',
  });

  @override
  State<WarnBuilder> createState() => _WarnBuilderState();
}

class _WarnBuilderState extends State<WarnBuilder> {
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
        BlurredContent(
          blurType: widget.blurType,
          child: widget.child,
        ),
        
        WarningOverlay(
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