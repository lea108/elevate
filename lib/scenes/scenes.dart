import 'package:elevate/router.dart';

enum GameScene {
  intro,
  building
  ;

  RouteId get route {
    return switch (this) {
      GameScene.intro => RouteId.intro,
      GameScene.building => RouteId.building,
    };
  }
}
