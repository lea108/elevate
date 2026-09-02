import 'dart:math';

import 'package:elevate/theme/palette.dart';
import 'package:elevate/utils/platform_adaptive.dart';
import 'package:material_ui/material_ui.dart';

class IntroOverlay extends StatelessWidget {
  const IntroOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final fgColor = Colors.orange[700];
    final mqSize = MediaQuery.sizeOf(context);
    final textTheme = TextTheme.of(context);
    final defaultStyle = textTheme.bodyLarge!.copyWith(color: fgColor);

    return IgnorePointer(
      child: Container(
        color: Palette.c3,
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Align(
            alignment: .center,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: min(500, mqSize.width - 32),
                maxHeight: mqSize.height,
              ),
              child: Column(
                crossAxisAlignment: .center,
                mainAxisSize: .max,
                children: [
                  SizedBox(height: mqSize.height * 0.08),
                  Text(
                    'Elevator Operator',
                    style: textTheme.displayMedium!.copyWith(color: fgColor),
                  ),
                  SizedBox(height: 30),
                  // dart format on
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(introBody),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    isDesktop ?
                    'Press any key to continue' : 'Tap to continue',
                    style: textTheme.titleLarge!.copyWith(color: fgColor),
                  ),
                  SizedBox(height: mqSize.height * 0.08),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// dart format off
const introBody =
'''In this game you work as an elevator operator.

Making the elevator go up and down so that people can get to their destination floor.

Sounds fun?
Lets get started! ''';
