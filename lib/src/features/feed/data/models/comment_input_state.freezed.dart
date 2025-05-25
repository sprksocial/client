// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_input_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CommentInputState {
  bool get canSubmit => throw _privateConstructorUsedError;
  bool get isPosting => throw _privateConstructorUsedError;
  List<XFile> get selectedImages => throw _privateConstructorUsedError;
  Map<String, String> get altTexts => throw _privateConstructorUsedError;
  TextEditingController get textController =>
      throw _privateConstructorUsedError;
  ImagePicker get imagePicker => throw _privateConstructorUsedError;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentInputStateCopyWith<CommentInputState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentInputStateCopyWith<$Res> {
  factory $CommentInputStateCopyWith(
          CommentInputState value, $Res Function(CommentInputState) then) =
      _$CommentInputStateCopyWithImpl<$Res, CommentInputState>;
  @useResult
  $Res call(
      {bool canSubmit,
      bool isPosting,
      List<XFile> selectedImages,
      Map<String, String> altTexts,
      TextEditingController textController,
      ImagePicker imagePicker});
}

/// @nodoc
class _$CommentInputStateCopyWithImpl<$Res, $Val extends CommentInputState>
    implements $CommentInputStateCopyWith<$Res> {
  _$CommentInputStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canSubmit = null,
    Object? isPosting = null,
    Object? selectedImages = null,
    Object? altTexts = null,
    Object? textController = null,
    Object? imagePicker = null,
  }) {
    return _then(_value.copyWith(
      canSubmit: null == canSubmit
          ? _value.canSubmit
          : canSubmit // ignore: cast_nullable_to_non_nullable
              as bool,
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedImages: null == selectedImages
          ? _value.selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      altTexts: null == altTexts
          ? _value.altTexts
          : altTexts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      textController: null == textController
          ? _value.textController
          : textController // ignore: cast_nullable_to_non_nullable
              as TextEditingController,
      imagePicker: null == imagePicker
          ? _value.imagePicker
          : imagePicker // ignore: cast_nullable_to_non_nullable
              as ImagePicker,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentInputStateImplCopyWith<$Res>
    implements $CommentInputStateCopyWith<$Res> {
  factory _$$CommentInputStateImplCopyWith(_$CommentInputStateImpl value,
          $Res Function(_$CommentInputStateImpl) then) =
      __$$CommentInputStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool canSubmit,
      bool isPosting,
      List<XFile> selectedImages,
      Map<String, String> altTexts,
      TextEditingController textController,
      ImagePicker imagePicker});
}

/// @nodoc
class __$$CommentInputStateImplCopyWithImpl<$Res>
    extends _$CommentInputStateCopyWithImpl<$Res, _$CommentInputStateImpl>
    implements _$$CommentInputStateImplCopyWith<$Res> {
  __$$CommentInputStateImplCopyWithImpl(_$CommentInputStateImpl _value,
      $Res Function(_$CommentInputStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? canSubmit = null,
    Object? isPosting = null,
    Object? selectedImages = null,
    Object? altTexts = null,
    Object? textController = null,
    Object? imagePicker = null,
  }) {
    return _then(_$CommentInputStateImpl(
      canSubmit: null == canSubmit
          ? _value.canSubmit
          : canSubmit // ignore: cast_nullable_to_non_nullable
              as bool,
      isPosting: null == isPosting
          ? _value.isPosting
          : isPosting // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedImages: null == selectedImages
          ? _value._selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
      altTexts: null == altTexts
          ? _value._altTexts
          : altTexts // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      textController: null == textController
          ? _value.textController
          : textController // ignore: cast_nullable_to_non_nullable
              as TextEditingController,
      imagePicker: null == imagePicker
          ? _value.imagePicker
          : imagePicker // ignore: cast_nullable_to_non_nullable
              as ImagePicker,
    ));
  }
}

/// @nodoc

class _$CommentInputStateImpl implements _CommentInputState {
  const _$CommentInputStateImpl(
      {this.canSubmit = false,
      this.isPosting = false,
      final List<XFile> selectedImages = const [],
      final Map<String, String> altTexts = const {},
      required this.textController,
      required this.imagePicker})
      : _selectedImages = selectedImages,
        _altTexts = altTexts;

  @override
  @JsonKey()
  final bool canSubmit;
  @override
  @JsonKey()
  final bool isPosting;
  final List<XFile> _selectedImages;
  @override
  @JsonKey()
  List<XFile> get selectedImages {
    if (_selectedImages is EqualUnmodifiableListView) return _selectedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedImages);
  }

  final Map<String, String> _altTexts;
  @override
  @JsonKey()
  Map<String, String> get altTexts {
    if (_altTexts is EqualUnmodifiableMapView) return _altTexts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_altTexts);
  }

  @override
  final TextEditingController textController;
  @override
  final ImagePicker imagePicker;

  @override
  String toString() {
    return 'CommentInputState(canSubmit: $canSubmit, isPosting: $isPosting, selectedImages: $selectedImages, altTexts: $altTexts, textController: $textController, imagePicker: $imagePicker)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentInputStateImpl &&
            (identical(other.canSubmit, canSubmit) ||
                other.canSubmit == canSubmit) &&
            (identical(other.isPosting, isPosting) ||
                other.isPosting == isPosting) &&
            const DeepCollectionEquality()
                .equals(other._selectedImages, _selectedImages) &&
            const DeepCollectionEquality().equals(other._altTexts, _altTexts) &&
            (identical(other.textController, textController) ||
                other.textController == textController) &&
            (identical(other.imagePicker, imagePicker) ||
                other.imagePicker == imagePicker));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      canSubmit,
      isPosting,
      const DeepCollectionEquality().hash(_selectedImages),
      const DeepCollectionEquality().hash(_altTexts),
      textController,
      imagePicker);

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentInputStateImplCopyWith<_$CommentInputStateImpl> get copyWith =>
      __$$CommentInputStateImplCopyWithImpl<_$CommentInputStateImpl>(
          this, _$identity);
}

abstract class _CommentInputState implements CommentInputState {
  const factory _CommentInputState(
      {final bool canSubmit,
      final bool isPosting,
      final List<XFile> selectedImages,
      final Map<String, String> altTexts,
      required final TextEditingController textController,
      required final ImagePicker imagePicker}) = _$CommentInputStateImpl;

  @override
  bool get canSubmit;
  @override
  bool get isPosting;
  @override
  List<XFile> get selectedImages;
  @override
  Map<String, String> get altTexts;
  @override
  TextEditingController get textController;
  @override
  ImagePicker get imagePicker;

  /// Create a copy of CommentInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentInputStateImplCopyWith<_$CommentInputStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
