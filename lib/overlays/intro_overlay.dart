import 'dart:math';

import 'package:elevate/theme/palette.dart';
import 'package:flutter/material.dart';

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
                    'Elevate',
                    style: textTheme.displayMedium!.copyWith(color: fgColor),
                  ),
                  SizedBox(height: 30),
                  // dart format on
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(introBody),
                          SizedBox(height: 50),
                          Text(
                            'Back story',
                            style: textTheme.titleLarge!.copyWith(
                              color: fgColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(backStoryBody),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    'Press any key to continue',
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

Making the elevator go up and down so that people can get to their destination floor.''';

const backStoryBody =
'''Your big brother is a real estate businessman but does not have the time to operate the elevator in their new high aiming property development.

So you are offered to operate the elevator and will be awarded tech coins⭐ from transporting people 🧍 in time to their destination floor.

Helping your brother out, perhaps will be good for business for both of you.

Sounds fun?
Lets get started!''';
