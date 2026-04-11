import 'package:elevate/game.dart';
import 'package:elevate/overlays/overlays.dart';
import 'package:elevate/overlays/widgets/economy_indicator.dart';
import 'package:elevate/theme/theme.dart';
import 'package:elevate/utils/dialog_backdrop.dart';
import 'package:flutter/material.dart';

/// Reactively shows EndOfDayReport dialog when ProgressState updates with a
/// new EndOfDayReport.
/// Clears the report when user closes dialog
class EndOfDayReportOverlay extends StatelessWidget {
  final MyGame game;

  const EndOfDayReportOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game.gameState.progressionState,
      builder: (context, child) {
        final progress = game.gameState.progressionState;
        final report = progress.endOfDayReport;
        if (report == null) {
          return Container();
        }
        return DialogBackdrop(
          onBeforeGamepadIntent: (activator, intent) {
            if (intent is DismissIntent) {
              close(false);
              return false;
            }
            return true;
          },
          child: AlertDialog(
            elevation: 18,
            title: Text('Day ${report.day + 1} report'),
            content: Column(
              mainAxisSize: .min,
              children: [
                Text(
                  'Transported (🧍): ${report.nTransported}\n'
                  'Late (☹️): ${report.nTransportedLate}\n'
                  'Very late (😡): ${report.nTransportedVeryLate}\n'
                  '\n'
                  'Tech coins (⭐): ${progress.techCoins}',
                ),
                Text('\n\nBuilding economy:'),
                SizedBox(height: mediumPadding),
                EconomyIndicator(
                  key: ValueKey(report.buildingEconomy),
                  value: report.buildingEconomy,
                  width: 200,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => close(true),
                child: Text('Open Tech Tree'),
              ),
              TextButton(onPressed: () => close(false), child: Text('Close')),
            ],
          ),
        );
      },
    );
  }

  void close(bool openTechTree) {
    final progress = game.gameState.progressionState;
    progress.clearEndOfDayReport();
    game.overlays.remove(GameOverlay.endOfDayReport.name);

    if (openTechTree) {
      game.overlays.add(GameOverlay.techTree.name);
    }
  }
}
