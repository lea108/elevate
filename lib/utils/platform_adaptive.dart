
import 'dart:io';

import 'package:elevate/utils/window/window.dart';
import 'package:flutter/foundation.dart';

bool get isDesktop {
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux || (kIsWeb && !isWebAndroid&& !isWebIOS);
}