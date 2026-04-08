import 'package:elevate/game.dart';
import 'package:elevate/theme/palette.dart';
import 'package:flutter/material.dart';

class TouchControlOverlay extends StatelessWidget {
  final MyGame game;
  const TouchControlOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .bottomRight,
      child: SizedBox(
        height: 250,
        width: 55,
        child: RotatedBox(
          quarterTurns: -1,
          child: ValueListenableBuilder(
            valueListenable: game.gameState.inputState.inputY,
            builder: (context, inputY, child) {
              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 5.5,
                  trackShape: RectangularSliderTrackShape(),
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: 15,
                    elevation: 2,
                    pressedElevation: 8,
                  ),
                  overlayColor: Colors.transparent,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                ),
                child: Slider(
                  value: -1 * inputY,
                  min: -1.0,
                  max: 1.0,
                  inactiveColor: Palette.c4,
                  activeColor: Palette.c4,
                  thumbColor: Color.lerp(Colors.brown, Colors.orange[200], 0.4),
                  onChanged: (value) {
                    game.gameState.inputState.inputY.value = (value * -1).clamp(
                      -1.0,
                      1.0,
                    );
                  },
                  onChangeEnd: (value) {
                    game.gameState.inputState.inputY.value = 0;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
