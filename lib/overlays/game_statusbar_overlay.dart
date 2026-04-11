import 'package:elevate/game.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/status_bar_section.dart';
import 'package:elevate/theme/responsive_layout.dart';
import 'package:elevate/utils/format.dart';
import 'package:elevate/theme/theme.dart';
import 'package:elevate/utils/sky_color.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class GameStatusbarOverlay extends StatelessWidget {
  final MyGame game;

  const GameStatusbarOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    bool narrow = narrowLayout(context);
    final insets = MediaQuery.viewPaddingOf(context);

    if (narrow) {
      return SafeArea(
        top: false,
        child: Column(
          children: [
            _sysStatusBarBackground(context, insets),
            Row(
              children: [
                Spacer(),
                _elevatorStatus(
                  context,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                    RoundedCorner.bottomRight,
                  },
                ),
                _transportedStatus(
                  context,
                  gapRight: false,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                  },
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                _timeStatus(
                  context,
                  placementTop: false,
                  gapRight: true,
                  roundedCorner: {
                    RoundedCorner.topRight,
                    if (insets.bottom > 0.1) ...[
                      RoundedCorner.bottomRight,
                    ],
                  },
                ),
                _techStatus(
                  context,
                  placementTop: false,
                  roundedCorner: {
                    RoundedCorner.topLeft,
                    RoundedCorner.topRight,
                    if (insets.bottom > 0.1) ...[
                      RoundedCorner.bottomLeft,
                      RoundedCorner.bottomRight,
                    ],
                  },
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: .topRight,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _sysStatusBarBackground(context, insets),
            Row(
              children: [
                _menu(
                  context,
                  roundedCorner: {
                    RoundedCorner.bottomRight,
                  },
                ),
                Spacer(),
                _techStatus(
                  context,
                  placementTop: true,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                    RoundedCorner.bottomRight,
                  },
                ),
                _elevatorStatus(
                  context,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                    RoundedCorner.bottomRight,
                  },
                ),
                _transportedStatus(
                  context,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                    RoundedCorner.bottomRight,
                  },
                ),
                _timeStatus(
                  context,
                  placementTop: true,
                  roundedCorner: {
                    RoundedCorner.bottomLeft,
                  },
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _sysStatusBarBackground(BuildContext context, EdgeInsets insets) {
    return SizedBox(
      height: insets.top > 0.1 ? insets.top + 4 : 0,
      child: ListenableBuilder(
        listenable: game.gameState.timeState,
        builder: (context, child) {
          return Container(
            color: resolveSkyColor(
              game.gameState.timeState.timeOfDay,
            ).darken(0.6),
          );
        },
      ),
    );
  }

  Widget _menu(
    BuildContext context, {
    Set<RoundedCorner> roundedCorner = const {},
  }) {
    return StatusBarSection(
      game: game,
      padding: EdgeInsets.zero,
      roundedCorner: roundedCorner,
      child: _Button(
        roundedCorner: roundedCorner,
        onPressed: () {
          game.overlays.add(GameOverlay.inGameMenu.name);
        },
        child: Icon(Icons.menu, size: 20),
      ),
    );
  }

  Widget _techStatus(
    BuildContext context, {
    bool placementTop = false,
    Set<RoundedCorner> roundedCorner = const {},
  }) {
    return ListenableBuilder(
      listenable: game.gameState.progressionState,
      builder: (context, _) {
        final progress = game.gameState.progressionState;
        final text = '⭐: ${progress.techCoins}';
        return StatusBarSection(
          game: game,
          padding: EdgeInsets.zero,
          roundedCorner: roundedCorner,
          useSkyColor: placementTop,
          gapRight: true,
          child: _Button(
            roundedCorner: roundedCorner,
            onPressed: () {
              game.overlays.add(GameOverlay.techTree.name);
            },
            child: Text(text),
          ),
        );
      },
    );
  }

  Widget _elevatorStatus(
    BuildContext context, {
    Set<RoundedCorner> roundedCorner = const {},
  }) {
    return ListenableBuilder(
      listenable: game.gameState.timeState,
      builder: (context, _) {
        final usage = game.gameState.elevatorState.occupancy;
        final cap = game.gameState.elevatorState.capacity;
        final text = '🛗 $usage / $cap';

        return StatusBarSection(
          key: Key(text),
          game: game,
          useSkyColor: true,
          roundedCorner: roundedCorner,
          gapRight: true,
          child: Text(text),
        );
      },
    );
  }

  Widget _transportedStatus(
    BuildContext context, {
    bool gapRight = true,
    Set<RoundedCorner> roundedCorner = const {},
  }) {
    return ListenableBuilder(
      listenable: game.gameState.progressionState,
      builder: (context, _) {
        final progress = game.gameState.progressionState;
        final gap = '  ';
        final base = '🧍: ${progress.nTransported} ';
        final late =
            '$gap☹️: ${progress.nTransportedLate} $gap😡: ${progress.nTransportedVeryLate}';
        final transported =
            base +
            ([
                  TutorialStage.elevators1Controls,
                  TutorialStage.elevators2Transport10,
                  TutorialStage.elevators4Destinations,
                ].contains(game.gameState.tutorialState.stage)
                ? ''
                : late);
        return StatusBarSection(
          game: game,
          useSkyColor: true,
          roundedCorner: roundedCorner,
          gapRight: gapRight,
          child: Text(transported),
        );
      },
    );
  }

  Widget _timeStatus(
    BuildContext context, {
    bool gapRight = false,
    bool placementTop = false,
    Set<RoundedCorner> roundedCorner = const {},
  }) {
    return ListenableBuilder(
      listenable: game.gameState.timeState,
      builder: (context, _) {
        final time = game.gameState.timeState;
        final t = formatTimeOfDay(time.timeOfDay);
        final timeText = ' $t day: ${time.day + 1}';
        final paused = time.paused;
        final fastForward = time.fastForward;

        return StatusBarSection(
          game: game,
          useSkyColor: placementTop,
          roundedCorner: roundedCorner,
          padding: EdgeInsets.zero,
          gapRight: gapRight,
          child: _Button(
            roundedCorner: roundedCorner,
            onPressed: () {
              game.overlays.add(GameOverlay.inGameMenu.name);
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 100),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Icon(
                    paused
                        ? Icons.pause
                        : (fastForward ? Icons.fast_forward : Icons.play_arrow),
                    size: 20,
                  ),
                  Text(timeText),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color backgroundColor(Color skyColor) {
    return skyColor.computeLuminance() > 0.70 * 3
        ? skyColor.darken(0.4)
        : Colors.transparent;
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

class _Button extends StatelessWidget {
  final Widget child;
  final Set<RoundedCorner> roundedCorner;
  final void Function() onPressed;

  const _Button({
    super.key,
    required this.onPressed,
    this.roundedCorner = const {},
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.all(mediumPadding + 4),
        ),
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
        shape: WidgetStateProperty.resolveWith((state) {
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.only(
              bottomLeft: roundedCorner.contains(RoundedCorner.bottomLeft)
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              bottomRight: roundedCorner.contains(RoundedCorner.bottomRight)
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              topLeft: roundedCorner.contains(RoundedCorner.topLeft)
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              topRight: roundedCorner.contains(RoundedCorner.topRight)
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
            ),
            side: state.contains(WidgetState.focused)
                ? focusedBorderSide.copyWith(strokeAlign: 1)
                : unfocusedBorderSide,
          );
        }),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
