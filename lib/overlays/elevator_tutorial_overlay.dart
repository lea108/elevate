import 'dart:async';
import 'dart:math';

import 'package:elevate/game.dart';
import 'package:elevate/models/state/tutorial_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/theme/palette.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

class ElevatorTutorialOverlay extends StatefulWidget {
  final MyGame game;

  const ElevatorTutorialOverlay(this.game, {super.key});

  @override
  State<ElevatorTutorialOverlay> createState() =>
      _ElevatorTutorialOverlayState();
}

class _ElevatorTutorialOverlayState extends State<ElevatorTutorialOverlay> {
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
    final tutorial = widget.game.gameState.tutorialState;
    final mqSize = MediaQuery.sizeOf(context);

    final width = 220.0;

    return Align(
      alignment: .center,
      child: Padding(
        padding: EdgeInsets.only(right: width + 50.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            minHeight: min(200, mqSize.height),
            maxHeight: min(700, mqSize.height),
          ),
          child: Card(
            elevation: 6,
            color: Palette.tutorialCardBg,
            child: Padding(
              padding: const EdgeInsets.all(mediumPadding),
              child: ListenableBuilder(
                listenable: tutorial,
                builder: (context, child) {
                  return Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...buildContent(
                        context,
                        tutorial.stage,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildContent(BuildContext context, TutorialStage stage) {
    switch (stage) {
      case TutorialStage.elevators1:
        return [
          Text(
            title1,
            style: TextTheme.of(context).titleMedium,
            textAlign: .center,
          ),
          SizedBox(height: mediumPadding),
          Text(bodyText1),
          Image.asset('assets/images/gamepad_elevator.png'),
          Text(
            'The game also works with keyboard using W-S or arrow up/down keys',
          ),
          Image.asset('assets/images/keys.png'),
          SizedBox(height: 30),
          Text('Objective:'),
          Text('Transport a person to the upper floor'),
          buildSkipButton(context, .elevators2),
        ];
      case TutorialStage.elevators2:
        return [
          Text(
            title2,
            style: TextTheme.of(context).titleMedium,
            textAlign: .center,
          ),
          SizedBox(height: mediumPadding),
          Text(bodyText2),
          //Image.asset('assets/images/tech_coin_info.png'),
          SizedBox(height: 30),
          Text('Objective:'),
          Text('Transport 10 people up or down.'),
          Text('\nProgress:'),
          SizedBox(height: 4),
          ..._progress(
            widget.game.gameState.tutorialState.transportedObjectiveProgress(),
            10,
          ),
          buildSkipButton(context, .elevators3),
        ];
      case TutorialStage.elevators3:
        return [
          Text(
            title3,
            style: TextTheme.of(context).titleMedium,
            textAlign: .center,
          ),
          SizedBox(height: mediumPadding),
          Text(bodyText3),
          SizedBox(height: 30),
          Text('Objective:'),
          Text('Transport people to both office floors'),
          ..._progress(
            widget.game.gameState.tutorialState.transportedObjectiveProgress(),
            2,
          ),
          buildSkipButton(context, .elevators4),
        ];
      case TutorialStage.elevators4:
        return [
          Text(
            title4,
            style: TextTheme.of(context).titleMedium,
            textAlign: .center,
          ),
          SizedBox(height: mediumPadding),
          Text(bodyText4),
          SizedBox(height: 30),
          Text('Objective:'),
          Text('Transport a late or very person up or down.'),
          buildSkipButton(context, .finalNotes),
        ];
      case TutorialStage.finalNotes:
        return [
          Text(
            'Great work!',
            style: TextTheme.of(context).titleMedium,
            textAlign: .center,
          ),
          SizedBox(height: mediumPadding),
          Text(finalNotes),
          buildSkipButton(context, .done, text: 'Close'),
        ];
      case TutorialStage.done:
        return [];
    }
  }

  Widget buildSkipButton(
    BuildContext context,
    TutorialStage skipTo, {
    String text = 'Skip',
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: ElevatedButton(
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(Palette.c1),
          foregroundColor: WidgetStatePropertyAll(Colors.white70),
        ),
        onPressed: () => skip(skipTo),
        child: Text(text),
      ),
    );
  }

  /// if [skipTo] is null, skip to next tutorial stage if possible
  void skip([TutorialStage? skipTo]) {
    skipTo ??= widget.game.gameState.tutorialState.stage.next;
    if (skipTo != null) {
      widget.game.gameState.tutorialState.stage = skipTo;
    }
  }

  List<Widget> _progress(int n, int target) {
    return [
      Text('\nProgress: ($n / $target)'),
      SizedBox(height: 4),
      LinearProgressIndicator(
        value: n / target,
      ),
    ];
  }

  void onGamepadEvent(GamepadEvent event) {
    final settings = widget.game.settingsState;
    if (settings.gamepadActivateButton.value.isPressed(event) == true) {
      skip();
    }
  }
}

// dart format off
const title1 = 'Elevators 🛗';
const bodyText1 =
"""Use the left stick on your gamepad to move the elevator up or down.
""";

const title2 = 'Move people and be rewarded';
const bodyText2 =
"""The building economy likes when people get to their offices.

If you are successful at moving people to their destinations, you will be awarded with tech coins (⭐).

You see your current saldo at the top right of the screen. With the ⭐:s you will be able to buy tech upgrades.
""";


const title3 = 'Where do people want to go?';
const bodyText3 =
"""People travel between "outside" and their office and then back again.

For now your elevator is very basic and does not tell you which floor people want to go off at. But there is an upgrade you can purchase to show this.
""";

const title4 = 'Don\'t be late ☹️😡';
const bodyText4 =
"""People don't have the whole day.

People will show in orange when they become late, and in red when they are very late.

Late people (☹️) will only give half of normal performance bonus.
Very late people (😡) gives you a negative performance score.

The score resets every new day though.
""";

const finalNotes =
"""You have completed the tutorial.

At the end of each day you will get your daily score and option to buy upgrades. The tech tree is also accessible via the game menu at any time.
""";