
String formatTimeOfDay(double time) {
  int t = time.floor();

  int h = (t/3600).floor();
  int m = ((t - h * 3600) /60).floor();
  int s = t - h * 3600 - m *60;

  //return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}