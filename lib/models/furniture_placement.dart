import 'dart:math';

import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:elevate/models/furniture_defs.dart';
import 'package:elevate/models/room_defs.dart';
import 'package:flame/game.dart';

List<FurnitureRef> generateRoomFurniture(
  RoomType roomType,
  RoomId roomId,
  int lvl,
) {
  if (roomType != .office) {
    return [];
  }
  if (roomId == .forRent) {
    return [];
  }

  final desk = randomChoice<FurnitureId>(
    [.deskA, .deskB, .deskC],
    switch (roomId) {
      .office1 => [0.85, 0.0, 0.15],
      .office2 => [0.6, 0.3, 0.1],
      .office3 => [0.3, 0.7, 0.0],
      _ => [0.0, 1.0, 0.0],
    },
  );
  final leftChair = randomChoice<FurnitureId>(
    [
      .chairGrayLeft,
      .chairBlueLeft,
      .chairRedLeft,
      .chairPurpleLeft,
    ],
    [
      1.0,
      switch (desk) {
        .deskA => 0.3,
        .deskB => 0.2,
        _ => 0.0,
      },
      switch (desk) {
        .deskA => 0.3,
        .deskB => 1.0,
        _ => 0.0,
      },
      desk == .deskA ? 0.1 : 0.0,
    ],
  );
  final FurnitureId rightChair = switch (leftChair) {
    .chairGrayLeft => .chairGrayRight,
    .chairBlueLeft => .chairBlueRight,
    .chairRedLeft => .chairRedRight,
    .chairPurpleLeft => .chairPurpleRight,
    _ => .chairGrayRight,
  };

  return _generateDesksWithChairs(desk, leftChair, rightChair);
}

List<FurnitureRef> _generateDesksWithChairs(
  FurnitureId desk,
  FurnitureId leftChair,
  FurnitureId rightChair,
) {
  final slopA = Random().nextInt(3);
  final slopB = Random().nextInt(3);

  final desk1Offset = Vector2(16.0 - slopA, 17.0);
  final desk2Offset = desk1Offset + Vector2(12, 0);
  final desk3Offset = desk1Offset + Vector2(42.0 + slopA + slopB, 0);
  final desk4Offset = desk3Offset + Vector2(12, 0);
  return [
    // table 1 - leftmost chair + table
    FurnitureRef(furnitureDefs[leftChair]!, desk1Offset + Vector2(-8, -1)),
    FurnitureRef(furnitureDefs[desk]!, desk1Offset),
    // table 2
    FurnitureRef(furnitureDefs[rightChair]!, desk2Offset + Vector2(7.5, -1)),
    FurnitureRef(furnitureDefs[desk]!, desk2Offset),
    // table 3
    FurnitureRef(furnitureDefs[leftChair]!, desk3Offset + Vector2(-8, -1)),
    FurnitureRef(furnitureDefs[desk]!, desk3Offset),
    // desk 4
    FurnitureRef(furnitureDefs[rightChair]!, desk4Offset + Vector2(7.5, -1)),
    FurnitureRef(furnitureDefs[desk]!, desk4Offset),
  ];
}
