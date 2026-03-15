class GameConsts {
  /// Set to true to load directly into the game, skipping intro
  static const bool skipIntro = false;
  static const int startTechCoins = 0;

  static const int worldWidth = 1000;
  static const int elevatorShaftW = 6;
  static const double elevatorCarW = 5;
  static const int elevatorX = 500 - 10 - elevatorShaftW;
  static const int maxFloorUp = 100;
  static const int maxFloorDown = 10;

  static const double officeHoursStartFrom = 7 * 3600;
  static const double officeHoursStartTo = 9 * 3600;
  static const double officeHoursEndFrom = 16 * 3600;
  static const double officeHoursEndTo = 18 * 3600;

  static const double lateMinTime = 45 * 60;
  static const double veryLateMinTime = 90 * 60;

  static const double indicatorOffOpacity = 0.0;

  static const String githubUrl = 'https://github.com/lea108/elevate';
}
