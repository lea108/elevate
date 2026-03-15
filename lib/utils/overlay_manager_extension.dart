import 'package:flame/src/game/overlay_manager.dart';

extension OverlayManagerExtension on OverlayManager {
  void setVisible(String name, bool visible) {
    if (activeOverlays.contains(name) != visible) {
      if (visible) {
        add(name);
      } else {
        remove(name);
      }
    }
  }
}
