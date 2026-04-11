import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gamepads/flutter_gamepads.dart';

class DialogBackdrop extends StatefulWidget {
  final Widget child;
  final bool Function(GamepadActivator activator, Intent intent)
  onBeforeGamepadIntent;
  const DialogBackdrop({
    required this.onBeforeGamepadIntent,
    required this.child,
    super.key,
  });

  @override
  State<DialogBackdrop> createState() => _DialogBackdropState();
}

class _DialogBackdropState extends State<DialogBackdrop> {
  final _focusScope = FocusScopeNode();

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusScope.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Color.fromARGB(50, 150, 150, 150),
        child: GamepadInterceptor(
          onBeforeIntent: widget.onBeforeGamepadIntent,
          child: FocusScope(
            node: _focusScope,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
