import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_settings_visibility_provider.g.dart';

@riverpod
class FeedSettingsVisibility extends _$FeedSettingsVisibility {
  @override
  bool build() {
    return false;
  }

  void setVisible(bool visible) {
    if (!ref.mounted) return;
    state = visible;
  }
}
