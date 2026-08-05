import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spark/src/features/media_editor/story/models/story_image_editor_result.dart';
import 'package:spark/src/features/posting/utils/captured_photo_flow.dart';

void main() {
  group('CapturedPhotoFlow', () {
    final photo = XFile('/tmp/captured.jpg');
    final editedPhoto = StoryImageEditorResult(image: XFile('/tmp/edited.jpg'));

    test('routes post photos directly to review', () async {
      XFile? reviewedPhoto;
      var storyEditorOpenCount = 0;
      var publishCount = 0;
      final flow = CapturedPhotoFlow(
        openPostReview: (photo) async => reviewedPhoto = photo,
        openStoryEditor: (photo) async {
          storyEditorOpenCount++;
          return editedPhoto;
        },
        publishStory: (editedPhoto) async {
          publishCount++;
          return true;
        },
      );

      final outcome = await flow.run(
        profile: CapturedPhotoProfile.post,
        photo: photo,
      );

      expect(reviewedPhoto?.path, photo.path);
      expect(storyEditorOpenCount, 0);
      expect(publishCount, 0);
      expect(outcome, CapturedPhotoFlowOutcome.returnedToRecorder);
    });

    test('edits and publishes Story photos', () async {
      var reviewCount = 0;
      StoryImageEditorResult? publishedPhoto;
      final flow = CapturedPhotoFlow(
        openPostReview: (photo) async => reviewCount++,
        openStoryEditor: (photo) async => editedPhoto,
        publishStory: (photo) async {
          publishedPhoto = photo;
          return true;
        },
      );

      final outcome = await flow.run(
        profile: CapturedPhotoProfile.story,
        photo: photo,
      );

      expect(reviewCount, 0);
      expect(publishedPhoto, same(editedPhoto));
      expect(outcome, CapturedPhotoFlowOutcome.exitedRecorder);
    });

    test('returns to the recorder when Story editing is canceled', () async {
      var publishCount = 0;
      final flow = CapturedPhotoFlow(
        openPostReview: (photo) async {},
        openStoryEditor: (photo) async => null,
        publishStory: (photo) async {
          publishCount++;
          return true;
        },
      );

      final outcome = await flow.run(
        profile: CapturedPhotoProfile.story,
        photo: photo,
      );

      expect(publishCount, 0);
      expect(outcome, CapturedPhotoFlowOutcome.returnedToRecorder);
    });

    test(
      'returns to the recorder when Story publishing does not complete',
      () async {
        final flow = CapturedPhotoFlow(
          openPostReview: (photo) async {},
          openStoryEditor: (photo) async => editedPhoto,
          publishStory: (photo) async => false,
        );

        final outcome = await flow.run(
          profile: CapturedPhotoProfile.story,
          photo: photo,
        );

        expect(outcome, CapturedPhotoFlowOutcome.returnedToRecorder);
      },
    );
  });
}
