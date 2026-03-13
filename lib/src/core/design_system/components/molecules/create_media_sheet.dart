import 'package:flutter/material.dart';

/// Shows a standardized bottom sheet for creating media:
/// Record, Upload Video, Upload Images.
/// Only renders the actions whose callbacks are provided (non-null).
Future<dynamic> showCreateMediaSheet(
  BuildContext context, {
  VoidCallback? onRecord,
  VoidCallback? onUploadVideo,
  VoidCallback? onUploadImages,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              if (onRecord != null)
                ListTile(
                  leading: Icon(Icons.camera_alt, color: colorScheme.onSurface),
                  title: Text(
                    'Record',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onRecord();
                  },
                ),
              if (onUploadVideo != null)
                ListTile(
                  leading: Icon(Icons.videocam, color: colorScheme.onSurface),
                  title: Text(
                    'Upload Video',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onUploadVideo();
                  },
                ),
              if (onUploadImages != null)
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: colorScheme.onSurface,
                  ),
                  title: Text(
                    'Upload Images',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    onUploadImages();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}
