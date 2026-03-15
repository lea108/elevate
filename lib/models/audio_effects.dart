import 'package:elevate/models/multi_play.dart';

class AudioClip {
  final String fileName;
  final String note;
  final int pitchDirection;
  int? activeLengthS;
  int? totalLengthS;

  AudioClip({
    required this.fileName,
    required this.note,
    required this.pitchDirection,
    this.activeLengthS,
    this.totalLengthS,
  });
}

class AudioEffects {
  static const _elevatorNotes = ['b2', 'c3', 'd3', 'e3', 'f3'];

  /// Map from note to pitchDirection to clip
  Map<String, Map<int, AudioClip>> _elevatorClips = {};

  late final MultiPlay _player;

  AudioEffects() {
    _player = MultiPlay('effects');

    for (var note in _elevatorNotes) {
      _elevatorClips[note] = {};
      for (var pitchDirection in [-1, 1]) {
        final fileName =
            'assets/audio/${note.replaceAll('3', '')}-pitch-${pitchDirection == 1 ? 'up' : 'down'}.mp3';
        _elevatorClips[note]![pitchDirection] = AudioClip(
          fileName: fileName,
          note: note,
          pitchDirection: pitchDirection,
        );
      }
    }
  }

  Future<void> elevatorStartMoveUp(int floor) async {
    final note = _floorToNote(floor);
    await _player.play(_elevatorClips[note]![1]!.fileName);
  }

  Future<void> elevatorStartMoveDown(int floor) async {
    final note = _floorToNote(floor);
    await _player.play(_elevatorClips[note]![1]!.fileName);
  }

  String _floorToNote(int floor) {
    int i = floor.clamp(-1, 3) + 1;
    return _elevatorNotes[i];
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
  }
}
