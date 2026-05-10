import 'package:elevate/models/game_consts.dart';
import 'package:elevate/scenes/building/building_scene.dart';
import 'package:elevate/scenes/intro/intro_scene.dart';
import 'package:flame/game.dart';

enum RouteId { intro, building }

RouterComponent createRouter({RouteId? initialRoute}) {
  return RouterComponent(
    initialRoute:
        (initialRoute ??
                (GameConsts.skipIntro ? RouteId.building : RouteId.intro))
            .name,
    routes: {
      RouteId.intro.name: WorldRoute(() => IntroScene(), maintainState: false),
      RouteId.building.name: WorldRoute(
        () => BuildingScene(),
        maintainState: false,
      ),
    },
  );
}
