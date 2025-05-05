import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

/// A generic result type that can represent either success or failure
@freezed
class Result<T> with _$Result<T> {
  /// Creates a success result with the given data
  const factory Result.success(T data) = Success<T>;
  
  /// Creates a failure result with an error message and optional exception
  const factory Result.failure(String message, [Exception? exception]) = Failure<T>;
} 