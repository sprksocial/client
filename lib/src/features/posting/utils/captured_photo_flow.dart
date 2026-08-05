import 'package:image_picker/image_picker.dart';
import 'package:spark/src/features/media_editor/story/models/story_image_editor_result.dart';

enum CapturedPhotoProfile { story, post }

enum CapturedPhotoFlowOutcome { returnedToRecorder, exitedRecorder }

typedef PostPhotoReviewLauncher = Future<void> Function(XFile photo);
typedef StoryPhotoEditorLauncher =
    Future<StoryImageEditorResult?> Function(XFile photo);
typedef StoryPhotoPublisher =
    Future<bool> Function(StoryImageEditorResult editedPhoto);

/// Dispatches a captured photo to the product flow selected by its profile.
class CapturedPhotoFlow {
  const CapturedPhotoFlow({
    required this.openPostReview,
    required this.openStoryEditor,
    required this.publishStory,
  });

  final PostPhotoReviewLauncher openPostReview;
  final StoryPhotoEditorLauncher openStoryEditor;
  final StoryPhotoPublisher publishStory;

  Future<CapturedPhotoFlowOutcome> run({
    required CapturedPhotoProfile profile,
    required XFile photo,
  }) async {
    switch (profile) {
      case CapturedPhotoProfile.post:
        await openPostReview(photo);
        return CapturedPhotoFlowOutcome.returnedToRecorder;
      case CapturedPhotoProfile.story:
        final editedPhoto = await openStoryEditor(photo);
        if (editedPhoto == null) {
          return CapturedPhotoFlowOutcome.returnedToRecorder;
        }

        final posted = await publishStory(editedPhoto);
        return posted
            ? CapturedPhotoFlowOutcome.exitedRecorder
            : CapturedPhotoFlowOutcome.returnedToRecorder;
    }
  }
}
