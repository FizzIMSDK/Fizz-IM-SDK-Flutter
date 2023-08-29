import 'package:fim_sdk/fim_sdk.dart';
import 'package:fixnum/fixnum.dart';

//异常类
class ResponseException implements Exception {
  final String? requestId;
  final int code;
  final String? reason;
  final Object? cause;
  final StackTrace? stackTrace;

  ResponseException(
      {this.requestId,
      required this.code,
      this.reason,
      this.cause,
      this.stackTrace});

  ResponseException.fromNotification(Protocol notification)
      : this(
      requestId:
      notification.fp!=null ? notification.fp : null,
      code: 1,
      reason: "notification.hasReason()" );

  @override
  int get hashCode =>
      requestId.hashCode ^
      code.hashCode ^
      reason.hashCode ^
      cause.hashCode ^
      stackTrace.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseException &&
          runtimeType == other.runtimeType &&
          requestId == other.requestId &&
          code == other.code &&
          reason == other.reason &&
          cause == other.cause &&
          stackTrace == other.stackTrace;

  @override
  String toString() => '$requestId:$code:$reason:$cause:$stackTrace';
}
