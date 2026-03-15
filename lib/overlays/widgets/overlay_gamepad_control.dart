import 'dart:async';

import 'package:elevate/game.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

class OverlayGamepadControl extends StatefulWidget {
  final MyGame game;
  final GameOverlay overlay;
  final Widget child;
  final bool? enabled;
  final void Function()? close;
  final void Function()? beforeActivate;
  const OverlayGamepadControl({
    required this.game,

    /// The overlay that will be closed when user presses the deselect button. Unless
    /// also [close] is provided.
    required this.overlay,
    required this.child,

    /// If provided, this method is called when user asks to close the overlay.
    /// No automatic close of overlay if this method is added.
    this.close,

    /// If provided, this method is called just before ActivateIntent is invoked
    this.beforeActivate,

    /// If provided and set to false, the gamepad control of the overlay is temporarily
    /// disabled.
    this.enabled,
    super.key,
  });

  @override
  State<OverlayGamepadControl> createState() => _OverlayGamepadControlState();
}

class _OverlayGamepadControlState extends State<OverlayGamepadControl> {
  StreamSubscription? _unsubscribe;

  @override
  void initState() {
    super.initState();
    _unsubscribe = Gamepads.events.listen(onGamepadEvent);
  }

  @override
  void dispose() {
    _unsubscribe?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void onGamepadEvent(GamepadEvent event) {
    if (widget.enabled == false) {
      return;
    }
    final game = widget.game;
    final settings = game.settingsState;
    if (settings.gamepadCancelButton.value.isPressed(event) == true) {
      if (widget.close != null) {
        widget.close!();
      } else {
        game.overlays.remove(widget.overlay.name);
      }
    }

    final navPrev =
        settings.gamepadDpadLeft.value.isPressed(event) == true ||
        settings.gamepadDpadUp.value.isPressed(event) == true;
    final navNext =
        settings.gamepadDpadRight.value.isPressed(event) == true ||
        settings.gamepadDpadDown.value.isPressed(event) == true;
    final navConfirm =
        settings.gamepadActivateButton.value.isPressed(event) == true;

    if (navPrev || navNext || navConfirm) {
      final primaryFocus = WidgetsBinding.instance.focusManager.primaryFocus;
      final focusedContext = primaryFocus?.context;

      if (navPrev) {
        FocusScope.of(context).previousFocus();
      }
      if (navNext) {
        FocusScope.of(context).nextFocus();
      }
      if (navConfirm) {
        if (focusedContext != null) {
          if (widget.beforeActivate != null) {
            widget.beforeActivate!();
          }
          Actions.maybeInvoke(focusedContext, ActivateIntent());
        }
      }
    }
  }
}
