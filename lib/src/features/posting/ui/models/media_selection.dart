import 'dart:collection';

import 'package:image_picker/image_picker.dart';

sealed class MediaLibrarySelection {
  const MediaLibrarySelection();
}

class SinglePhotoSelection extends MediaLibrarySelection {
  const SinglePhotoSelection(this.photo);

  final XFile photo;
}

class SingleVideoSelection extends MediaLibrarySelection {
  const SingleVideoSelection(this.video);

  final XFile video;
}

class MultiPhotoSelection extends MediaLibrarySelection {
  MultiPhotoSelection(List<XFile> photos)
    : photos = UnmodifiableListView<XFile>(photos);

  final List<XFile> photos;
}
