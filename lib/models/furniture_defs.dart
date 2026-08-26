import 'package:flame/components.dart';

enum FurnitureId {
  deskA,
  deskB,
  deskC,
  chairBlueLeft,
  chairBlueRight,
  chairRedLeft,
  chairRedRight,
  chairPurpleLeft,
  chairPurpleRight,
  chairGrayLeft,
  chairGrayRight,
}

class FurnitureDef {
  final FurnitureId furnitureId;
  final String spriteName;

  const FurnitureDef(this.furnitureId, this.spriteName);
}

Map<FurnitureId, FurnitureDef> furnitureDefs = {
  FurnitureId.deskA: FurnitureDef(.deskA, 'furniture_desk_a.png'),
  FurnitureId.deskB: FurnitureDef(.deskB, 'furniture_desk_b.png'),
  FurnitureId.deskC: FurnitureDef(.deskC, 'furniture_desk_c.png'),
  FurnitureId.chairBlueLeft: FurnitureDef(
    .chairBlueLeft,
    'furniture_chair_blue_left.png',
  ),
  FurnitureId.chairBlueRight: FurnitureDef(
    .chairBlueRight,
    'furniture_chair_blue_right.png',
  ),
  FurnitureId.chairRedLeft: FurnitureDef(
    .chairRedLeft,
    'furniture_chair_red_left.png',
  ),
  FurnitureId.chairRedRight: FurnitureDef(
    .chairRedRight,
    'furniture_chair_red_right.png',
  ),
  FurnitureId.chairPurpleLeft: FurnitureDef(
    .chairPurpleLeft,
    'furniture_chair_purple_left.png',
  ),
  FurnitureId.chairPurpleRight: FurnitureDef(
    .chairPurpleRight,
    'furniture_chair_purple_right.png',
  ),
  FurnitureId.chairGrayLeft: FurnitureDef(
    .chairGrayLeft,
    'furniture_chair_gray_left.png',
  ),
  FurnitureId.chairGrayRight: FurnitureDef(
    .chairGrayRight,
    'furniture_chair_gray_right.png',
  ),
};

Map<FurnitureId, Sprite> furnitureSprites = {};
