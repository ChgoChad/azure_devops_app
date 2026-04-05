import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

mixin AppLogger {
  String? _tag;

  // ignore: use_setters_to_change_properties
  void setTag(String tag) {
    _tag = tag;
  }

  /// Logs only if [kDebugMode]
  void logDebug(String msg) {
    if (kDebugMode) log(msg, name: _tag ?? '');
  }

  /// Logs on Sentry with level info only if ![kDebugMode]
  void logInfo(String msg) {
    if (kDebugMode) return;

    Sentry.captureMessage(msg);
  }

  /// Logs exception on Sentry with level error only if ![kDebugMode]
  void logError(Object? exception, Object stacktrace) {
    if (kDebugMode) {
      logDebug('Error: $exception');
      return;
    }

    Sentry.captureException(exception, stackTrace: stacktrace);
  }

  /// Logs message on Sentry with level error only if ![kDebugMode]
  void logErrorMessage(String message) {
    if (kDebugMode) {
      logDebug('Error: $message');
      return;
    }

    final tagStr = (_tag ?? '').isNotEmpty ? '[$_tag] ' : '';
    final errorMessage = '${tagStr}Error: $message';
    Sentry.captureMessage(errorMessage, level: SentryLevel.error);
  }

}
