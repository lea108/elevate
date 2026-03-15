import 'package:elevate/game.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class StatusBarSection extends StatelessWidget {
  final MyGame game;
  final Widget child;
  final EdgeInsets? padding;
  final bool roundBottomLeft;
  final bool roundBottomRight;
  final bool gapRight;
  const StatusBarSection({
    required this.game,
    this.padding,
    this.gapRight = false,
    this.roundBottomLeft = false,
    this.roundBottomRight = false,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.gameState.timeState,
      builder: (context, child) {
        final time = game.gameState.timeState;
        return Padding(
          padding: gapRight
              ? const EdgeInsets.only(right: 20)
              : EdgeInsets.zero,
          child: Container(
            padding: padding ?? EdgeInsets.all(mediumPadding + 2),
            decoration: boxDecoration(
              time.skyColor,
              roundBottomLeft: roundBottomLeft,
              roundBottomRight: roundBottomRight,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Color backgroundColor(Color skyColor) {
    return skyColor.darken(0.4);
    /*
    return skyColor..computeLuminance() > 0.70 * 3
        ? skyColor.darken(0.4)
        : Colors.transparent;
    */
  }

  BoxDecoration boxDecoration(
    Color skyColor, {
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    return BoxDecoration(
      color: backgroundColor(skyColor),
      borderRadius: BorderRadius.only(
        bottomLeft: roundBottomLeft
            ? Radius.circular(mediumPadding)
            : Radius.zero,
        bottomRight: roundBottomRight
            ? Radius.circular(mediumPadding)
            : Radius.zero,
      ),
    );
  }
}
