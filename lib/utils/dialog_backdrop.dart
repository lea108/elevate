import 'dart:ui';

import 'package:flutter/material.dart';

class DialogBackdrop extends StatelessWidget {
  final Widget child;
  const DialogBackdrop({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final mqSize = MediaQuery.sizeOf(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Color.fromARGB(50, 150, 150, 150),
        child: FocusScope(
          canRequestFocus: true,
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
