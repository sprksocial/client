# Review page redesign QA

final result: passed

## Target and evidence

- Approved target: `/Users/knotbin/.codex/generated_images/01a07cf9-24dd-7003-bfec-31665a5a26c8/exec-93745e48-91e2-4acc-9fd3-a709256e85c4.png`.
- Photo implementation: `/Users/knotbin/.codex/visualizations/2026/09/07/01a07cf9-24dd-7003-bfec-31665a5a26c8/photo-review-implemented.png`.
- App-content comparison crop: same directory, `photo-review-content.png`.
- Keyboard evidence: same directory, `photo-review-keyboard.png`.
- Video template renders: same directory, `video-review-dark.png` and `video-review-light.png`.

The selected concept is photo review with two portrait tiles, an add tile, direct tap-to-edit, caption, sound, crosspost, and a bottom Post action. There is no selection state or alt-text action. Video adopts the same form and footer with one centered preview and preparation status. The subsequent video refinement increases portrait preview height to 38% of the viewport (220–340 pixels), centers it horizontally, and lets landscape previews use their natural height. The video captures were refreshed after this change; all five video layout tests and focused analysis passed.

## Comparison

The approved mock is 853×1844 pixels (approximately 390×844 logical pixels). The live iPhone Air simulator window is 469×999 pixels, including device chrome. The 415×820 app-content crop excludes the status bar and bezel. Both the target and crop were opened together for the comparison. Video template captures are 390×844 at 1×, rendered using the app's actual theme and SN Pro font.

Photo content: two real simulator-library images, caption “A little waterfall detour.”, no sound, crosspost off. The second real image differs from the generated concept's valley image. Device safe areas and stock app typography explain minor proportional differences; this is a responsive implementation, not a raster reproduction. Video captures use a static waterfall fixture to inspect layout, not a live upload or playback session.

- Typography: existing SN Pro styles retained, caption and settings readable, one clear primary action.
- Spacing: single horizontal strip, 20-pixel page margins, comfortable caption area, restrained setting rows, persistent footer. Content scrolls when keyboard or large text reduces available height.
- Colors: existing light/dark tokens; pink Post action and neutral secondary controls. Video progress uses pink with a neutral track.
- Images: real photo tiles, rounded corners, no duplicate hero image or selection outline. Full photo editing opens from the tapped tile. Video preview preserves its supplied aspect ratio in a bounded region.
- Copy: all new user-facing labels are localized. Add-photo tooltip, per-photo accessible labels, and conditional crosspost warning are retained.

Full-view captures made text, image treatment, and controls readable; separate region crops were unnecessary.

## Iteration history

1. Initial simulator comparison found the add tile used a circled plus. Replaced it with the existing plain add symbol; the final photo capture shows the correction.
2. Initial video render exposed Flutter's unrelated progress-track accent. Set the track to the app's neutral surface color; final light/dark video captures verify the correction.
3. A temporary image capture harness initially stalled on image precaching, then produced an unloaded frame. Those captures were rejected. The final harness decodes the fixture before rendering; final captures show the image. The temporary harness was removed from the repository.

No actionable P0/P1/P2 visual differences remain. The solid add-tile border intentionally reuses the existing component treatment instead of introducing a custom dashed painter.

The subsequent requested refinement removes the tap-to-edit helper and its spacing; the photo tiles remain directly tappable. The saved photo captures precede that text-only refinement.

## Validation and limits

- Live simulator: add photo, open second photo in editor, cancel back to review, type caption, show/dismiss software keyboard. Post remains above the keyboard.
- Widget regressions: 11 tests cover editing/removal indices, sound, empty-post prevention, add limit, posting locks, 320×568 with safe areas/keyboard/text scale 2, video aspect ratios, and upload retry/processing states.
- Full Flutter suite: 789 tests passed.
- App, Widgetbook and test-source analysis passed; touched-source formatting and diff checks passed.
- Read-only production correctness review found no actionable defects.
- Native video playback and actual publishing were not exercised during this redesign. Existing playback and upload tests pass; controller ownership and teardown were preserved.
