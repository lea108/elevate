import 'package:elevate/theme/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EconomyIndicator extends StatelessWidget {
  final double value;
  final double width;
  const EconomyIndicator({required this.value, required this.width, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, _height),
      painter: EconomyIndicatorPainter(value),
    );
  }
}

final _height = 30.0;
final _arrowW = 10.0;
final _centerGap = 0.0;
final _neutralColor = Colors.orange;
final _positiveColor = Colors.green;
final _negativeColor = Colors.red;

class EconomyIndicatorPainter extends CustomPainter {
  final double inputValue;

  EconomyIndicatorPainter(this.inputValue);

  @override
  void paint(Canvas canvas, Size size) {
    final areaW =
        ((size.width - _centerGap) / _arrowW).floorToDouble() * _arrowW;
    final areaX1 = size.width / 2 - areaW / 2;
    final areaX2 = size.width / 2 + areaW / 2;
    final gapX1 = size.width / 2 - _centerGap / 2;
    final gapX2 = size.width / 2 - _centerGap / 2;

    // x is center of arrow
    for (var x = areaX1 + _arrowW / 2; x < areaX2 - _arrowW / 2; x += _arrowW) {
      if (x >= gapX1 && x < gapX2) {
        // skip over the gap
        x = gapX2 + _arrowW / 2;
      }

      /// [-1.0, 1.0]
      final arrowValue =
          (x - areaX1 - _arrowW / 2) / (areaW - _arrowW) * 2 - 1.0;
      _drawArrow(canvas, size, x, arrowValue);
    }

    final vLineAlpha = _alphaAtValue(0.0);
    final vLinePaint = Paint()..color = _neutralColor.withAlpha(vLineAlpha);
    //canvas.drawLine(Offset(0, _height/ 2), Offset(size.width, _height / 2), paint)
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, _height),
      vLinePaint,
    );
  }

  /// Returns null on neutral, true on negative and false on positive side
  ScaleSide _side(double value) {
    if (value < -0.01) {
      return ScaleSide.negative;
    }
    if (value > 0.01) {
      return ScaleSide.positive;
    }
    return ScaleSide.neutral;
  }

  Color _sideToColor(ScaleSide side) {
    return switch (side) {
      ScaleSide.negative => _negativeColor,
      ScaleSide.neutral => _neutralColor,
      ScaleSide.positive => _positiveColor,
    };
  }

  double _strengthAtValue(double drawValue) {
    const range = 0.2;
    final baseStrength =
        (range - (inputValue - drawValue).abs().clamp(0, range)) / range;

    final valueSide = _side(inputValue);
    final drawSide = _side(drawValue);

    if (valueSide == drawSide) {
      return baseStrength;
    } else {
      if (valueSide == .neutral || drawSide == .neutral) {
        return baseStrength / 2;
      }
      return 0;
    }
  }

  int _alphaAtValue(double drawValue) {
    return (_strengthAtValue(drawValue) * 255).round();
  }

  void _drawArrow(Canvas canvas, Size size, double x, double arrowValue) {
    final arrowAlpha = _alphaAtValue(arrowValue);
    if (arrowAlpha == 0) return;

    final side = _side(arrowValue);
    final paint = Paint()
      ..color = _sideToColor(side).withAlpha(
        arrowAlpha,
      );

    final shift = 5;
    final deltaScale = arrowValue > 0
        ? (0.3 + arrowValue).clamp(0, 1)
        : (-0.3 - arrowValue).clamp(-1, 0);
    final delta = _arrowW / 2 * deltaScale;

    canvas.drawLine(
      Offset(x - delta + shift, 0),
      Offset(x + delta + shift, _height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(x - delta + shift, _height),
      Offset(x + delta + shift, _height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! EconomyIndicatorPainter ||
        oldDelegate.inputValue != inputValue;
  }
}

enum ScaleSide {
  neutral,
  negative,
  positive,
}
