import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:elevate/theme/palette.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';

class TechCard extends StatelessWidget {
  final TechData data;
  final bool firstInRow;
  final bool activated;
  final bool canActivate;
  final bool selected;
  final void Function() onPressed;
  const TechCard(
    this.data, {
    required this.firstInRow,
    required this.activated,
    required this.canActivate,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  Color get backgroundColor {
    if (activated) return Palette.c4;
    if (!canActivate) return Palette.c4;
    return selected ? Palette.tutorialCardBg : Palette.tutorialCardBg;
  }

  Color get foregroundColor {
    if (!canActivate) return Colors.white70;
    return Colors.white;
  }

  double get elevation {
    if (!canActivate || activated) return 1;
    return selected ? 6 : 4;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: mediumPadding, bottom: mediumPadding),
      child: Row(
        children: [
          if (!firstInRow)
            SizedBox(
              width: 30,
              child: Center(
                child: Icon(Icons.chevron_right),
              ),
            ),

          SizedBox(
            height: 220,
            width: 200,
            child: ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                elevation: WidgetStatePropertyAll(elevation),
                backgroundColor: WidgetStatePropertyAll(backgroundColor),
                foregroundColor: WidgetStatePropertyAll(foregroundColor),
                padding: WidgetStatePropertyAll(
                  EdgeInsetsGeometry.all(mediumPadding * 2),
                ),
                side: WidgetStateBorderSide.resolveWith((state) {
                  if (state.contains(WidgetState.focused)) {
                    return BorderSide(width: 3, color: Colors.orange);
                  }
                  if (selected) {
                    return BorderSide(
                      width: 3,
                      color: Color.lerp(Colors.orange, Colors.white24, 0.6)!,
                    );
                  }
                  return BorderSide(width: 3, color: Colors.transparent);
                }),
              ),
              onPressed: canActivate ? onPressed : null,
              child: Column(
                children: [
                  Text(
                    data.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: mediumPadding),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: ImageFiltered(
                      imageFilter: ColorFilter.saturation(
                        activated || canActivate ? 1.0 : 0.3,
                      ),
                      child: Image.asset('assets/images/${data.spriteName}'),
                    ),
                  ),
                  SizedBox(height: mediumPadding),
                  Text(
                    data.description,
                    style: TextStyle(fontSize: 12),
                  ),
                  Spacer(),
                  Text(activated ? 'Activated ✅' : 'Price: ${data.cost} ⭐'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
