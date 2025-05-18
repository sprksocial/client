// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_review_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ImageReviewState {
  List<XFile> get imageFiles => throw _privateConstructorUsedError;
  Map<String, String> get altTexts => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isPosting => throw _privateConstructorUsedError;

  /// Create a copy of ImageReviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageReviewStateCopyWith<ImageReviewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageReviewStateCopyWith<$Res> {
  factory $ImageReviewStateCopyWith(
          ImageReviewState value, $Res Function(ImageReviewState) then) =
      _$ImageReviewStateCopyWithImpl<$Res, ImageReviewState>;
  @useResult
  $Res call(
      {List<XFile> imageFiles,
      Map<String, String> altTexts,
      int currentPage,
      String description,
      bool isPosting});
}

/// @nodoc
class _$ImageReviewStateCopyWithImpl<$Res, $Val extends ImageReviewState>
    implements $ImageReviewStateCopyWith<$Res> {
  _$ImageReviewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageReviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageFiles = null,
    Object? altTexts = null,
    Object? currentPage = null,
    Object? description = null,
    Object? isPosting = null,
  }) {
    return _then(_value.copyWith(
      imageFiles: null == imageFiles
          ? _value.imageFiles
          : imageFiles // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      altTexts: null == altTexts
          ? _value.altTexts
          : altTexts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageReviewStateImplCopyWith<$Res>
    implements $ImageReviewStateCopyWith<$Res> {
  factory _$$ImageReviewStateImplCopyWith(_$ImageReviewStateImpl value,
          $Res Function(_$ImageReviewStateImpl) then) =
      __$$ImageReviewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<XFile> imageFiles,
      Map<String, String> altTexts,
      int currentPage,
      String description,
      bool isPosting});
}

/// @nodoc
class __$$ImageReviewStateImplCopyWithImpl<$Res>
    extends _$ImageReviewStateCopyWithImpl<$Res, _$ImageReviewStateImpl>
    implements _$$ImageReviewStateImplCopyWith<$Res> {
  __$$ImageReviewStateImplCopyWithImpl(_$ImageReviewStateImpl _value,
      $Res Function(_$ImageReviewStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageReviewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageFiles = null,
    Object? altTexts = null,
    Object? currentPage = null,
    Object? description = null,
    Object? isPosting = null,
  }) {
    return _then(_$ImageReviewStateImpl(
      imageFiles: null == imageFiles
          ? _value._imageFiles
          : imageFiles // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      altTexts: null == altTexts
          ? _value._altTexts
          : altTexts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ImageReviewStateImpl
    with DiagnosticableTreeMixin
    implements _ImageReviewState {
  const _$ImageReviewStateImpl(
      {required final List<XFile> imageFiles,
      required final Map<String, String> altTexts,
      required this.currentPage,
      this.description = '',
      this.isPosting = false})
      : _imageFiles = imageFiles,
        _altTexts = altTexts;

  final List<XFile> _imageFiles;
  @override
  List<XFile> get imageFiles {
    if (_imageFiles is EqualUnmodifiableListView) return _imageFiles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageFiles);
  }

  final Map<String, String> _altTexts;
  @override
  Map<String, String> get altTexts {
    if (_altTexts is EqualUnmodifiableMapView) return _altTexts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_altTexts);
  }

  @override
  final int currentPage;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final bool isPosting;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ImageReviewState(imageFiles: $imageFiles, altTexts: $altTexts, currentPage: $currentPage, description: $description, isPosting: $isPosting)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ImageReviewState'))
      ..add(DiagnosticsProperty('imageFiles', imageFiles))
      ..add(DiagnosticsProperty('altTexts', altTexts))
      ..add(DiagnosticsProperty('currentPage', currentPage))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('isPosting', isPosting));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageReviewStateImpl &&
            const DeepCollectionEquality()
                .equals(other._imageFiles, _imageFiles) &&
            const DeepCollectionEquality().equals(other._altTexts, _altTexts) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isPosting, isPosting) ||
                other.isPosting == isPosting));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_imageFiles),
      const DeepCollectionEquality().hash(_altTexts),
      currentPage,
      description,
      isPosting);

  /// Create a copy of ImageReviewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageReviewStateImplCopyWith<_$ImageReviewStateImpl> get copyWith =>
      __$$ImageReviewStateImplCopyWithImpl<_$ImageReviewStateImpl>(
          this, _$identity);
}

abstract class _ImageReviewState implements ImageReviewState {
  const factory _ImageReviewState(
      {required final List<XFile> imageFiles,
      required final Map<String, String> altTexts,
      required final int currentPage,
      final String description,
      final bool isPosting}) = _$ImageReviewStateImpl;

  @override
  List<XFile> get imageFiles;
  @override
  Map<String, String> get altTexts;
  @override
  int get currentPage;
  @override
  String get description;
  @override
  bool get isPosting;

  /// Create a copy of ImageReviewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageReviewStateImplCopyWith<_$ImageReviewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
