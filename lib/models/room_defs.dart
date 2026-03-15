enum RoomType {
  empty,
  office,
  groundFloor,
  garage,
}

class RoomDef {
  final RoomId id;
  final int width;
  final String spriteName;
  final RoomType roomType;

  RoomDef(this.id, this.width, this.roomType, this.spriteName);
}

enum RoomId {
  empty,
  groundLevel,
  forRent,
  office1,
  office2,
  office3,
  garage1,
  garage2,
}

const officeWidth = 10;
const groundLevelWidth = 5;

// dart format off
final Map<RoomId, RoomDef> roomDefs = {
  RoomId.empty: RoomDef(RoomId.empty, 1, RoomType.empty, 'empty.png'),
  RoomId.groundLevel: RoomDef(RoomId.groundLevel, groundLevelWidth, RoomType.groundFloor, 'ground_floor.png'),
  RoomId.forRent: RoomDef(RoomId.forRent, officeWidth, RoomType.office, 'for_rent.png'),
  RoomId.office1: RoomDef(RoomId.office1, officeWidth, RoomType.office, 'office1.png'),
  RoomId.office2: RoomDef(RoomId.office2, officeWidth, RoomType.office, 'office2.png'),
  RoomId.office3: RoomDef(RoomId.office3, officeWidth, RoomType.office, 'office3.png'),
  RoomId.garage1: RoomDef(RoomId.garage1, 5, RoomType.garage, 'garage1.png'),
  RoomId.garage2: RoomDef(RoomId.garage2, 5, RoomType.garage, 'garage2.png'),
};