import 'dart:math';

import 'package:collection/collection.dart';
import 'package:elevate/game.dart';
import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/overlay_gamepad_control.dart';
import 'package:elevate/overlays/widgets/tech_card.dart';
import 'package:elevate/theme/palette.dart';
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
  DateTime? lastGamepadActivate;
  static final _purchaseFocusNode = FocusNode();
  String? error;

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
        beforeActivate: () {
          lastGamepadActivate = DateTime.now();
        },
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
                                        error = null;
                                      });
                                      // If selected by gamepad, autofocus the Purchase button
                                      if (lastGamepadActivate != null &&
                                          lastGamepadActivate!
                                              .add(Duration(milliseconds: 100))
                                              .isAfter(DateTime.now())) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              _purchaseFocusNode.requestFocus();
                                            });
                                      }
                                    },
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: mediumPadding * 2),
                    Text(
                      'Selected: ${selectedData?.name ?? 'none'}',
                      style: TextTheme.of(context).titleMedium,
                    ),
                    Text(
                      'Tech coins saldo: ${progress.techCoins} ⭐',
                      style: TextTheme.of(context).titleMedium,
                    ),
                    if (error != null)
                      Text(
                        error!,
                        style:
                            TextTheme.of(
                              context,
                            ).titleMedium!.copyWith(
                              color: Colors.red[700],
                              fontWeight: .bold,
                            ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  focusNode: _purchaseFocusNode,
                  onPressed: selected != null ? purchaseSelected : null,
                  child: Text(
                    'Pay ${selectedData?.cost ?? 0} ⭐',
                    style: selected != null
                        ? Theme.of(
                            context,
                          ).textTheme.titleMedium!
                        : null,
                  ),
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
    final tutorial = widget.game.gameState.tutorialState;

    final result = techTree.activateTech(
      selected!,
      progress,
      elevator,
      agents,
      tutorial,
    );
    if (result.success) {
      setState(() {
        selected = null;
      });
    } else {
      setState(() {
        error = result.errorStr ?? 'Error';
      });
    }
  }

  void close() {
    widget.game.overlays.remove(GameOverlay.techTree.name);
  }
}
