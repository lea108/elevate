import 'package:elevate/game.dart';
import 'package:elevate/models/state/time_state.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/status_bar_section.dart';
import 'package:elevate/theme/responsive_layout.dart';
import 'package:elevate/utils/format.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class GameStatusbarOverlay extends StatelessWidget {
  final MyGame game;

  const GameStatusbarOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    bool narrow = narrowLayout(context);

    if (narrow) {
      return Column(
        children: [
          Row(
            children: [
              Spacer(),
              _elevatorStatus(context),
              _transportedStatus(context, topRight: true),
            ],
          ),
          Spacer(),
          Row(
            children: [
              _timeStatus(context, bottomLeft: true),
              _techStatus(context, placementBottom: true),
              Spacer(),
            ],
          ),
        ],
      );
    }

    return Align(
      alignment: .topRight,
      child: Row(
        children: [
          _menu(context, topLeft: true),
          Spacer(),
          _techStatus(context, placementTop: true),
          _elevatorStatus(context),
          _transportedStatus(context),
          _timeStatus(context, topRight: true),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, {bool topLeft = true}) {
    return StatusBarSection(
      game: game,
      padding: EdgeInsets.zero,
      roundBottomRight: topLeft,
      child: _Button(
        roundBottomRight: topLeft,
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
    bool placementBottom = false,
  }) {
    return ListenableBuilder(
      listenable: game.gameState.progressionState,
      builder: (context, _) {
        final progress = game.gameState.progressionState;
        final text = '⭐: ${progress.techCoins}';
        return StatusBarSection(
          game: game,
          padding: EdgeInsets.zero,
          roundBottomLeft: placementTop,
          roundBottomRight: placementTop,
          roundTopLeft: placementBottom,
          roundTopRight: placementBottom,
          gapRight: true,
          child: _Button(
            roundBottomLeft: placementTop,
            roundBottomRight: placementTop,
            roundTopLeft: placementBottom,
            roundTopRight: placementBottom,
            onPressed: () {
              game.overlays.add(GameOverlay.techTree.name);
            },
            child: Text(text),
          ),
        );
      },
    );
  }

  Widget _elevatorStatus(BuildContext context) {
    return ListenableBuilder(
      listenable: game.gameState.timeState,
      builder: (context, _) {
        final usage = game.gameState.elevatorState.occupancy;
        final cap = game.gameState.elevatorState.capacity;
        final text = '🛗 $usage / $cap';

        return StatusBarSection(
          key: Key(text),
          game: game,
          roundBottomLeft: true,
          roundBottomRight: true,
          gapRight: true,
          child: Text(text),
        );
      },
    );
  }

  Widget _transportedStatus(BuildContext context, {bool topRight = false}) {
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
          roundBottomLeft: true,
          roundBottomRight: !topRight,
          gapRight: !topRight,
          child: Text(transported),
        );
      },
    );
  }

  Widget _timeStatus(
    BuildContext context, {
    bool bottomLeft = false,
    bool topRight = false,
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
          roundBottomLeft: topRight,
          roundTopRight: bottomLeft,
          padding: EdgeInsets.zero,
          gapRight: !topRight,
          child: _Button(
            roundBottomLeft: topRight,
            roundTopRight: bottomLeft,
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
  final bool roundBottomLeft;
  final bool roundBottomRight;
  final bool roundTopLeft;
  final bool roundTopRight;
  final void Function() onPressed;

  const _Button({
    super.key,
    required this.onPressed,
    this.roundBottomLeft = false,
    this.roundBottomRight = false,
    this.roundTopLeft = false,
    this.roundTopRight = false,
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
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.only(
              bottomLeft: roundBottomLeft
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              bottomRight: roundBottomRight
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              topLeft: roundTopLeft
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
              topRight: roundTopRight
                  ? Radius.circular(mediumPadding)
                  : Radius.zero,
            ),
          ),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
