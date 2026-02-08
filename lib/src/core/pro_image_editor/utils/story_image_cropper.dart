import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Utility to crop images to story aspect ratio (9:16 / 1080x1920).
class StoryImageCropper {
  StoryImageCropper._();

  /// Target story dimensions.
  static const double targetWidth = 1080;
  static const double targetHeight = 1920;
  static const double targetAspectRatio = targetWidth / targetHeight; // 0.5625

  /// Crops the given image file to 9:16 aspect ratio (center crop).
  ///
  /// Returns the path to the cropped image file.
  static Future<File> cropToStoryAspectRatio(File imageFile) async {
    // Decode the image
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final originalWidth = image.width.toDouble();
    final originalHeight = image.height.toDouble();
    final originalAspectRatio = originalWidth / originalHeight;

    // Calculate crop area (center crop to 9:16)
    double cropWidth;
    double cropHeight;
    double cropX;
    double cropY;

    if (originalAspectRatio > targetAspectRatio) {
      // Image is wider than 9:16 - crop horizontally
      cropHeight = originalHeight;
      cropWidth = originalHeight * targetAspectRatio;
      cropX = (originalWidth - cropWidth) / 2;
      cropY = 0;
    } else {
      // Image is taller than 9:16 - crop vertically
      cropWidth = originalWidth;
      cropHeight = originalWidth / targetAspectRatio;
      cropX = 0;
      cropY = (originalHeight - cropHeight) / 2;
    }

    // Create a picture recorder to draw the cropped image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw the cropped portion scaled to target size
    final srcRect = Rect.fromLTWH(cropX, cropY, cropWidth, cropHeight);
    const dstRect = Rect.fromLTWH(0, 0, targetWidth, targetHeight);

    canvas.drawImageRect(image, srcRect, dstRect, Paint());

    // Convert to image
    final picture = recorder.endRecording();
    final croppedImage = await picture.toImage(
      targetWidth.toInt(),
      targetHeight.toInt(),
    );

    // Encode to PNG
    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final pngBytes = byteData!.buffer.asUint8List();

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final croppedFile = File('${tempDir.path}/story_cropped_$timestamp.png');
    await croppedFile.writeAsBytes(pngBytes);

    // Clean up
    image.dispose();
    croppedImage.dispose();

    return croppedFile;
  }

  /// Checks if an image needs to be cropped to 9:16 aspect ratio.
  static Future<bool> needsCropping(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final aspectRatio = image.width / image.height;
    image.dispose();

    // Allow small tolerance for floating point comparison
    return (aspectRatio - targetAspectRatio).abs() > 0.01;
  }
}
