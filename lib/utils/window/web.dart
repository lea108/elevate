// ignore: avoid_web_libraries_in_flutter
import 'package:flutter/semantics.dart';
import 'package:web/web.dart' as web;

import 'package:flutter/foundation.dart';

String get webHref {
  return web.window.location.href;
}

void webHistoryPushState(dynamic data, String title, String url) {
  web.window.history.pushState(data, title, url);
}

bool get isWebIOS {
  // print(web.window.navigator.platform);
  final maxTouch = web.window.navigator.maxTouchPoints;
  return kIsWeb &&
      [
        'iPad Simulator',
        'iPhone Simulator',
        'iPod Simulator',
        'iPad',
        'iPhone',
        'iPod',
        'MacIntel' // iPad pro
      ].contains(web.window.navigator.platform) && maxTouch > 0;
}

bool get isWebAndroid {
  return kIsWeb &&
      web.window.navigator.userAgent.toLowerCase().contains('android');
}

String? get navigatorPlatform {
  return web.window.navigator.platform;
}

String get navigatorUserAgent {
  return web.window.navigator.userAgent;
}

/// Enables the semantics tree on web
void enableWebSemantics() {
  SemanticsBinding.instance.ensureSemantics();
}
