// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_video_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateVideoState {
  /// Current camera mode (photo or video)
  CameraMode get mode => throw _privateConstructorUsedError;

  /// Whether video recording is in progress
  bool get isRecording => throw _privateConstructorUsedError;

  /// Current recording progress (0.0 to 1.0)
  double get recordingProgress => throw _privateConstructorUsedError;

  /// Current recording time display text
  String get recordingTimeText => throw _privateConstructorUsedError;

  /// Recording time in seconds
  int get recordingSeconds => throw _privateConstructorUsedError;

  /// Max recording time in seconds
  int get maxRecordingSeconds =>
      throw _privateConstructorUsedError; // 3 minutes
  /// Whether camera permission is denied
  bool get cameraPermissionDenied => throw _privateConstructorUsedError;

  /// Whether to show auth prompt
  bool get showAuthPrompt => throw _privateConstructorUsedError;

  /// Error message, if any
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CreateVideoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateVideoStateCopyWith<CreateVideoState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateVideoStateCopyWith<$Res> {
  factory $CreateVideoStateCopyWith(
          CreateVideoState value, $Res Function(CreateVideoState) then) =
      _$CreateVideoStateCopyWithImpl<$Res, CreateVideoState>;
  @useResult
  $Res call(
      {CameraMode mode,
      bool isRecording,
      double recordingProgress,
      String recordingTimeText,
      int recordingSeconds,
      int maxRecordingSeconds,
      bool cameraPermissionDenied,
      bool showAuthPrompt,
      String? error});
}

/// @nodoc
class _$CreateVideoStateCopyWithImpl<$Res, $Val extends CreateVideoState>
    implements $CreateVideoStateCopyWith<$Res> {
  _$CreateVideoStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateVideoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? isRecording = null,
    Object? recordingProgress = null,
    Object? recordingTimeText = null,
    Object? recordingSeconds = null,
    Object? maxRecordingSeconds = null,
    Object? cameraPermissionDenied = null,
    Object? showAuthPrompt = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as CameraMode,
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingProgress: null == recordingProgress
          ? _value.recordingProgress
          : recordingProgress // ignore: cast_nullable_to_non_nullable
              as double,
      recordingTimeText: null == recordingTimeText
          ? _value.recordingTimeText
          : recordingTimeText // ignore: cast_nullable_to_non_nullable
              as String,
      recordingSeconds: null == recordingSeconds
          ? _value.recordingSeconds
          : recordingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxRecordingSeconds: null == maxRecordingSeconds
          ? _value.maxRecordingSeconds
          : maxRecordingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      cameraPermissionDenied: null == cameraPermissionDenied
          ? _value.cameraPermissionDenied
          : cameraPermissionDenied // ignore: cast_nullable_to_non_nullable
              as bool,
      showAuthPrompt: null == showAuthPrompt
          ? _value.showAuthPrompt
          : showAuthPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateVideoStateImplCopyWith<$Res>
    implements $CreateVideoStateCopyWith<$Res> {
  factory _$$CreateVideoStateImplCopyWith(_$CreateVideoStateImpl value,
          $Res Function(_$CreateVideoStateImpl) then) =
      __$$CreateVideoStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CameraMode mode,
      bool isRecording,
      double recordingProgress,
      String recordingTimeText,
      int recordingSeconds,
      int maxRecordingSeconds,
      bool cameraPermissionDenied,
      bool showAuthPrompt,
      String? error});
}

/// @nodoc
class __$$CreateVideoStateImplCopyWithImpl<$Res>
    extends _$CreateVideoStateCopyWithImpl<$Res, _$CreateVideoStateImpl>
    implements _$$CreateVideoStateImplCopyWith<$Res> {
  __$$CreateVideoStateImplCopyWithImpl(_$CreateVideoStateImpl _value,
      $Res Function(_$CreateVideoStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateVideoState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mode = null,
    Object? isRecording = null,
    Object? recordingProgress = null,
    Object? recordingTimeText = null,
    Object? recordingSeconds = null,
    Object? maxRecordingSeconds = null,
    Object? cameraPermissionDenied = null,
    Object? showAuthPrompt = null,
    Object? error = freezed,
  }) {
    return _then(_$CreateVideoStateImpl(
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as CameraMode,
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingProgress: null == recordingProgress
          ? _value.recordingProgress
          : recordingProgress // ignore: cast_nullable_to_non_nullable
              as double,
      recordingTimeText: null == recordingTimeText
          ? _value.recordingTimeText
          : recordingTimeText // ignore: cast_nullable_to_non_nullable
              as String,
      recordingSeconds: null == recordingSeconds
          ? _value.recordingSeconds
          : recordingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      maxRecordingSeconds: null == maxRecordingSeconds
          ? _value.maxRecordingSeconds
          : maxRecordingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      cameraPermissionDenied: null == cameraPermissionDenied
          ? _value.cameraPermissionDenied
          : cameraPermissionDenied // ignore: cast_nullable_to_non_nullable
              as bool,
      showAuthPrompt: null == showAuthPrompt
          ? _value.showAuthPrompt
          : showAuthPrompt // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CreateVideoStateImpl implements _CreateVideoState {
  const _$CreateVideoStateImpl(
      {this.mode = CameraMode.video,
      this.isRecording = false,
      this.recordingProgress = 0.0,
      this.recordingTimeText = '00:00 / 03:00',
      this.recordingSeconds = 0,
      this.maxRecordingSeconds = 180,
      this.cameraPermissionDenied = false,
      this.showAuthPrompt = false,
      this.error});

  /// Current camera mode (photo or video)
  @override
  @JsonKey()
  final CameraMode mode;

  /// Whether video recording is in progress
  @override
  @JsonKey()
  final bool isRecording;

  /// Current recording progress (0.0 to 1.0)
  @override
  @JsonKey()
  final double recordingProgress;

  /// Current recording time display text
  @override
  @JsonKey()
  final String recordingTimeText;

  /// Recording time in seconds
  @override
  @JsonKey()
  final int recordingSeconds;

  /// Max recording time in seconds
  @override
  @JsonKey()
  final int maxRecordingSeconds;
// 3 minutes
  /// Whether camera permission is denied
  @override
  @JsonKey()
  final bool cameraPermissionDenied;

  /// Whether to show auth prompt
  @override
  @JsonKey()
  final bool showAuthPrompt;

  /// Error message, if any
  @override
  final String? error;

  @override
  String toString() {
    return 'CreateVideoState(mode: $mode, isRecording: $isRecording, recordingProgress: $recordingProgress, recordingTimeText: $recordingTimeText, recordingSeconds: $recordingSeconds, maxRecordingSeconds: $maxRecordingSeconds, cameraPermissionDenied: $cameraPermissionDenied, showAuthPrompt: $showAuthPrompt, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateVideoStateImpl &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.isRecording, isRecording) ||
                other.isRecording == isRecording) &&
            (identical(other.recordingProgress, recordingProgress) ||
                other.recordingProgress == recordingProgress) &&
            (identical(other.recordingTimeText, recordingTimeText) ||
                other.recordingTimeText == recordingTimeText) &&
            (identical(other.recordingSeconds, recordingSeconds) ||
                other.recordingSeconds == recordingSeconds) &&
            (identical(other.maxRecordingSeconds, maxRecordingSeconds) ||
                other.maxRecordingSeconds == maxRecordingSeconds) &&
            (identical(other.cameraPermissionDenied, cameraPermissionDenied) ||
                other.cameraPermissionDenied == cameraPermissionDenied) &&
            (identical(other.showAuthPrompt, showAuthPrompt) ||
                other.showAuthPrompt == showAuthPrompt) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      mode,
      isRecording,
      recordingProgress,
      recordingTimeText,
      recordingSeconds,
      maxRecordingSeconds,
      cameraPermissionDenied,
      showAuthPrompt,
      error);

  /// Create a copy of CreateVideoState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateVideoStateImplCopyWith<_$CreateVideoStateImpl> get copyWith =>
      __$$CreateVideoStateImplCopyWithImpl<_$CreateVideoStateImpl>(
          this, _$identity);
}

abstract class _CreateVideoState implements CreateVideoState {
  const factory _CreateVideoState(
      {final CameraMode mode,
      final bool isRecording,
      final double recordingProgress,
      final String recordingTimeText,
      final int recordingSeconds,
      final int maxRecordingSeconds,
      final bool cameraPermissionDenied,
      final bool showAuthPrompt,
      final String? error}) = _$CreateVideoStateImpl;

  /// Current camera mode (photo or video)
  @override
  CameraMode get mode;

  /// Whether video recording is in progress
  @override
  bool get isRecording;

  /// Current recording progress (0.0 to 1.0)
  @override
  double get recordingProgress;

  /// Current recording time display text
  @override
  String get recordingTimeText;

  /// Recording time in seconds
  @override
  int get recordingSeconds;

  /// Max recording time in seconds
  @override
  int get maxRecordingSeconds; // 3 minutes
  /// Whether camera permission is denied
  @override
  bool get cameraPermissionDenied;

  /// Whether to show auth prompt
  @override
  bool get showAuthPrompt;

  /// Error message, if any
  @override
  String? get error;

  /// Create a copy of CreateVideoState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateVideoStateImplCopyWith<_$CreateVideoStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
