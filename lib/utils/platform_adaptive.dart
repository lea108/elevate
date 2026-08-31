import 'dart:io';

import 'package:elevate/utils/window/window.dart';
import 'package:flutter/foundation.dart';

bool get isDesktop {
  return kIsWeb
      ? !isWebAndroid && !isWebIOS
      : Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
