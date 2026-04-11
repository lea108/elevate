import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:elevate/theme/palette.dart';
import 'package:elevate/theme/theme.dart';
import 'package:flutter/material.dart';

class TechCard extends StatelessWidget {
  final TechData data;
  final bool isVertical;
  final bool isFirstInTechBranch;
  final bool lastInTechBranch;
  final bool activated;
  final bool canActivate;
  final bool selected;
  final void Function() onPressed;
  const TechCard(
    this.data, {
    required this.isVertical,
    required this.isFirstInTechBranch,
    required this.lastInTechBranch,
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
    bool showFull = !isVertical || selected || activated;
    return Padding(
      padding: isVertical
          ? EdgeInsets.zero
          : const EdgeInsets.only(top: mediumPadding, bottom: mediumPadding),
      child: Flex(
        direction: isVertical ? Axis.vertical : Axis.horizontal,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isFirstInTechBranch && isVertical)
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Icon(Icons.chevron_right),
                  ),
                ),
              if (isVertical && !isFirstInTechBranch) SizedBox(width: 30),
              SizedBox(
                height: isVertical ? (showFull ? 150 : 66) : 200,
                width: isVertical ? 250 : 200,
                child: ElevatedButton(
                  style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    elevation: WidgetStatePropertyAll(elevation),
                    backgroundColor: WidgetStatePropertyAll(backgroundColor),
                    foregroundColor: WidgetStatePropertyAll(foregroundColor),
                    padding: WidgetStatePropertyAll(
                      EdgeInsetsGeometry.all(
                        narrowPadding * 2,
                      ),
                    ),
                    side: WidgetStateBorderSide.resolveWith((state) {
                      if (state.contains(WidgetState.focused)) {
                        return BorderSide(width: 3, color: Colors.orange);
                      }
                      if (selected) {
                        return BorderSide(
                          width: 3,
                          color: Palette.selectedTechBorder,
                        );
                      }
                      return BorderSide(width: 3, color: Colors.transparent);
                    }),
                  ),
                  onPressed: canActivate ? onPressed : null,
                  child: Column(
                    children: [
                      if (isVertical)
                        Row(
                          children: [
                            if (isVertical) ...[
                              _buildImage(),
                            ],
                            Text(
                              data.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              activated ? '✅' : '${data.cost} ⭐',
                            ),
                          ],
                        )
                      else ...[
                        Text(
                          data.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: mediumPadding),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: _buildImage(),
                        ),
                      ],
                      if (showFull) ...[
                        SizedBox(height: mediumPadding),
                        Text(
                          data.description,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                      Spacer(),
                      if (!isVertical)
                        Text(
                          activated ? 'Activated ✅' : 'Price: ${data.cost} ⭐',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!lastInTechBranch)
            Padding(
              padding: isVertical
                  ? const EdgeInsets.only(left: 30.0)
                  : EdgeInsets.zero,
              child: SizedBox(
                width: 30,
                height: isVertical ? 30 : null,
                child: Center(
                  child: Icon(
                    isVertical ? Icons.expand_more : Icons.chevron_right,
                  ),
                ),
              ),
            ),
          if (lastInTechBranch && isVertical) SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ImageFiltered(
      imageFilter: ColorFilter.saturation(
        activated || canActivate ? 1.0 : 0.3,
      ),
      child: Image.asset('assets/images/${data.spriteName}'),
    );
  }
}
