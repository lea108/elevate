import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:elevate/utils/audio_cache.dart';

class MultiPlay {
  final List<AudioPlayer> _players = [];

  final List<StreamSubscription> _unsubscribe = [];

  MultiPlay(String prefix) {
    for (var i in [0, 1, 2, 4]) {
      final player = AudioPlayer(playerId: '$prefix-player-$i');
      player.audioCache = rootAudioCache;
      _players.add(player);
    }
  }

  Future<void> dispose() async {
    for (var u in _unsubscribe) {
      u.cancel();
    }
    await _players.map((p) => p.dispose()).wait;
  }

  Future<void> play(String fileName) async {
    final iFree = _players.indexWhere((p) => p.state != .playing);
    if (iFree != -1) {
      await _players[iFree].setSource(AssetSource(fileName));
      await _players[iFree].resume();
      return;
    }

    // All players are taken.
    // For now just fail
    print('Not playing $fileName - all ${_players.length} players are busy');
  }

  void setVolume(double volume) {
    for (var player in _players) {
      player.setVolume(volume);
    }
  }
}
