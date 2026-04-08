import 'package:elevate/game.dart';
import 'package:elevate/theme/palette.dart';
import 'package:elevate/theme/responsive_layout.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

enum RoundedCorner {
  bottomLeft,
  bottomRight,
  topLeft,
  topRight,
}

class StatusBarSection extends StatelessWidget {
  final MyGame game;
  final Widget child;
  final EdgeInsets? padding;
  final Set<RoundedCorner> roundedCorner;
  final bool useSkyColor;
  final bool gapRight;
  const StatusBarSection({
    required this.game,
    this.padding,
    this.gapRight = false,
    this.useSkyColor = true,
    this.roundedCorner = const {},
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = narrowLayout(context);
    final gapSize = narrow ? 20.0 : 10.0;

    return Padding(
      padding: gapRight ? EdgeInsets.only(right: gapSize) : EdgeInsets.zero,
      child: Builder(
        builder: (context) {
          if (useSkyColor) {
            return ListenableBuilder(
              listenable: game.gameState.timeState,
              builder: (context, child) {
                final time = game.gameState.timeState;
                return buildContainer(context, time.skyColor);
              },
              child: child,
            );
          } else {
            return buildContainer(context, Palette.groundColor);
          }
        },
      ),
    );
  }

  Widget buildContainer(BuildContext context, Color skyColor) {
    return Container(
      padding: padding ?? EdgeInsets.all(mediumPadding),
      decoration: boxDecoration(
        skyColor,
        roundBottomLeft: roundedCorner.contains(RoundedCorner.bottomLeft),
        roundBottomRight: roundedCorner.contains(RoundedCorner.bottomRight),
        roundTopLeft: roundedCorner.contains(RoundedCorner.topLeft),
        roundTopRight: roundedCorner.contains(RoundedCorner.topRight),
      ),
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
    bool roundTopLeft = false,
    bool roundTopRight = false,
  }) {
    const round = Radius.circular(mediumPadding);
    return BoxDecoration(
      color: backgroundColor(skyColor),
      borderRadius: BorderRadius.only(
        bottomLeft: roundBottomLeft ? round : .zero,
        bottomRight: roundBottomRight ? round : .zero,
        topLeft: roundTopLeft ? round : .zero,
        topRight: roundTopRight ? round : .zero,
      ),
    );
  }
}
