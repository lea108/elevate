
// On Flutter Web the web.dart file is exported, otherwise not_web.dart
export 'not_web.dart'
  if (dart.library.js_interop) 'web.dart';