import 'dart:async';
import 'dart:io';

import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:azure_devops/src/services/share_intent_service.dart';
import 'package:flutter/material.dart';

class LifecycleListener extends StatefulWidget {
  const LifecycleListener({super.key, required this.child});

  final Widget child;

  @override
  State<LifecycleListener> createState() => _LifecycleListenerState();
}

class _LifecycleListenerState extends State<LifecycleListener> with WidgetsBindingObserver, AppLogger {
  Timer? _inactiveTimer;
  bool _hasAlreadyLogged = false;
  AppLifecycleState? _previousState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactiveTimer?.cancel();
    _inactiveTimer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final user = context.api.user;

    if (state == AppLifecycleState.inactive && _previousState != AppLifecycleState.paused) {
      if (user != null && !_hasAlreadyLogged) {
        logInfo('Session finished');
        _hasAlreadyLogged = true;
        _inactiveTimer = Timer(Duration(seconds: 300), () => _hasAlreadyLogged = false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (Platform.isAndroid && user != null) {
        ShareIntentService().maybeHandleSharedUrl();
      }
    }

    _previousState = state;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
