import 'dart:math';

import 'package:collection/collection.dart';
import 'package:elevate/game.dart';
import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/overlay_gamepad_control.dart';
import 'package:elevate/overlays/widgets/tech_card.dart';
import 'package:elevate/utils/dialog_backdrop.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';

class TechTreeOverlay extends StatefulWidget {
  final MyGame game;
  const TechTreeOverlay(this.game, {super.key});

  @override
  State<TechTreeOverlay> createState() => _TechTreeOverlayState();
}

class _TechTreeOverlayState extends State<TechTreeOverlay> {
  TechId? selected;

  TechData? get selectedData => selected != null
      ? widget.game.gameState.techTreeState.resolveTechData(selected!)
      : null;

  @override
  Widget build(BuildContext context) {
    final progress = widget.game.gameState.progressionState;
    final techTree = widget.game.gameState.techTreeState;

    final windowSize = widget.game.camera.viewport.size;

    return DialogBackdrop(
      child: OverlayGamepadControl(
        game: widget.game,
        overlay: GameOverlay.techTree,
        child: ListenableBuilder(
          listenable: techTree,
          builder: (context, child) {
            return AlertDialog(
              title: Text('Tech tree'),
              content: SizedBox(
                width: min(windowSize.x - mediumPadding * 2, 670),
                height: min(windowSize.y - mediumPadding * 2, 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: techTree.techCatalog.length,
                        prototypeItem:
                            techTree.techCatalog.isNotEmpty &&
                                techTree.techCatalog.first.isNotEmpty
                            ? TechCard(
                                techTree.techCatalog.first.first,
                                firstInRow: true,
                                activated: false,
                                canActivate: false,
                                selected: true,
                                onPressed: () {},
                              )
                            : null,
                        itemBuilder: (context, i) {
                          final techLane = techTree.techCatalog[i];
                          return Row(
                            children: techLane
                                .mapIndexed(
                                  (i, t) => TechCard(
                                    t,
                                    firstInRow: i == 0,
                                    activated: techTree.isActivated(t.id),
                                    canActivate: techTree.canActivate(t.id),
                                    selected: selected == t.id,
                                    onPressed: () {
                                      setState(() {
                                        selected = t.id;
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: mediumPadding * 2),
                    Row(
                      children: [
                        Text(
                          'Tech coins (⭐) saldo: ${progress.techCoins}',
                          style: TextTheme.of(context).titleMedium,
                        ),
                        if (selected != null) ...[
                          SizedBox(width: 20),
                          Text(
                            'To pay: ${selectedData?.cost}',
                            style: TextTheme.of(context).titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: selected != null ? purchaseSelected : null,
                  child: Text('Purchase'),
                ),
                TextButton(onPressed: close, child: Text('Close')),
              ],
            );
          },
        ),
      ),
    );
  }

  void purchaseSelected() {
    if (selected == null) {
      return;
    }

    final techTree = widget.game.gameState.techTreeState;
    final progress = widget.game.gameState.progressionState;
    final elevator = widget.game.gameState.elevatorState;
    final agents = widget.game.gameState.agentsState;

    final result = techTree.activateTech(selected!, progress, elevator, agents);
    if (result.success) {
      setState(() {
        selected = null;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text(result.errorStr ?? ''),
        ),
      );
    }
  }

  void close() {
    widget.game.overlays.remove(GameOverlay.techTree.name);
  }
}
