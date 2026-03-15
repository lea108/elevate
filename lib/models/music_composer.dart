import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:elevate/models/multi_play.dart';
import 'package:elevate/utils/audio_cache.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MusicPice {
  final String fileName;
  final int happiness;
  final int probability;
  final int octave;
  final int activeLengthS;
  final int totalLengthS;

  MusicPice({
    required this.fileName,
    required this.happiness,
    required this.probability,
    required this.octave,
    required this.activeLengthS,
    required this.totalLengthS,
  });
}

class PlayClip {
  final MusicPice? clip;
  final double startTime;
  final double endTime;

  bool started = false;

  PlayClip(this.clip, this.startTime, this.endTime);

  double get activeEnd => startTime + (clip?.activeLengthS ?? 0);
  double get endtime => startTime + endTime;
}

class MusicComposer {
  final List<MusicPice> _clips = [];
  final List<AudioPlayer> _players = [];
  late final MultiPlay _player;

  double t = 0;
  double _generatedTo = -1;
  int _nextPlayerI = 0;

  final List<StreamSubscription> _unsubscribe = [];

  List<PlayClip> _schedule = [];
  //Map<int, List<PlayClip>> _schedule = {};

  MusicComposer() {
    _clips.addAll([
      MusicPice(
        fileName: 'notes1.mp3',
        happiness: 4,
        probability: 5,
        octave: 4,
        activeLengthS: 10,
        totalLengthS: 14,
      ),
      MusicPice(
        fileName: 'notes4.mp3',
        happiness: 3,
        probability: 3,
        octave: 4,
        activeLengthS: 5,
        totalLengthS: 7,
      ),
      MusicPice(
        fileName: 'notes6.mp3',
        happiness: 3,
        probability: 5,
        octave: 4,
        activeLengthS: 6,
        totalLengthS: 8,
      ),
      MusicPice(
        fileName: 'notes7.mp3',
        happiness: 3,
        probability: 5,
        octave: 2,
        activeLengthS: 4,
        totalLengthS: 7,
      ),
      MusicPice(
        fileName: 'notes8.mp3',
        happiness: 3,
        probability: 3,
        octave: 4,
        activeLengthS: 4,
        totalLengthS: 7,
      ),
      MusicPice(
        fileName: 'notes9.mp3',
        happiness: 3,
        probability: 3,
        octave: 4,
        activeLengthS: 5,
        totalLengthS: 8,
      ),
      MusicPice(
        fileName: 'notes9.mp3',
        happiness: 2,
        probability: 3,
        octave: 3,
        activeLengthS: 5,
        totalLengthS: 8,
      ),
      MusicPice(
        fileName: 'notes10.mp3',
        happiness: 3,
        probability: 1,
        octave: 3,
        activeLengthS: 6,
        totalLengthS: 10,
      ),
      //      MusicPice(
      //        fileName: 'notes11.mp3',
      //        happiness: 1,
      //        probability: 1,
      //        octave: 2,
      //        activeLengthS: 8,
      //        totalLengthS: 12,
      //      ),
      //      MusicPice(
      //        fileName: 'notes12.mp3',
      //        happiness: 1,
      //        probability: 1,
      //        octave: 2,
      //        activeLengthS: 8,
      //        totalLengthS: 12,
      //      ),
      MusicPice(
        fileName: 'notes13.mp3',
        happiness: 3,
        probability: 5,
        octave: 3,
        activeLengthS: 4,
        totalLengthS: 6,
      ),
      MusicPice(
        fileName: 'notes14.mp3',
        happiness: 1,
        probability: 1,
        octave: 1,
        activeLengthS: 5,
        totalLengthS: 8,
      ),
    ]);

    _player = MultiPlay('music');
    for (var i in [0, 1, 2]) {
      final player = AudioPlayer(playerId: 'player-$i');
      player.audioCache = rootAudioCache;
      _players.add(player);
    }
  }

  Future<void> dispose() async {
    for (var u in _unsubscribe) {
      u.cancel();
    }
    await _players.map((p) => p.dispose()).wait;
    await _player.dispose();
  }

  /// [elevatorFloorRatio] a value [0, 1] giving the ratio of current floor of elevator
  void update(double dt, double elevatorFloorRatio) {
    t += dt;

    _removePastClips();
    _generate(elevatorFloorRatio);
    _startPlayClips();
  }

  void _removePastClips() {
    _schedule.removeWhere((c) => c.endTime <= t);
  }

  void _generate(double elevatorFloorRatio) {
    if (t < _generatedTo) {
      return;
    }

    final r = Random();

    final currentHappyness =
        _schedule.fold(0, (past, c) => past + (c.clip?.happiness ?? 0)) /
        max(1, _schedule.length);
    final targetHappyness = currentHappyness + r.nextDoubleBetween(-1, 1);

    final targetOctave = 1 + 5 * elevatorFloorRatio;

    List<double> weights = [];
    for (var c in _clips) {
      final h = 2 / max(0.001, (targetHappyness - c.happiness).abs());
      final o = 2 / max(0.001, (targetOctave - c.octave).abs());
      final p = c.probability;
      weights.add(h * o * p);
    }

    final clip = randomChoice(_clips, weights);
    _scheduleClip(clip, _generatedTo);
    _generatedTo += clip.activeLengthS.toDouble() - 0.5;
  }

  _scheduleClip(MusicPice clip, double startTime) {
    _schedule.add(PlayClip(clip, startTime, startTime + clip.totalLengthS));
  }

  _startPlayClips() async {
    for (var c in _schedule) {
      if (!c.started && t >= c.startTime && c.clip != null) {
        c.started = true;
        _player.play('assets/audio/${c.clip!.fileName}');

        //        final player = _players[_nextPlayerI];
        //        _nextPlayerI = (_nextPlayerI + 1) % _players.length;
        //
        //        c.started = true;
        //
        //        await player.setSource(
        //          AssetSource('assets/audio/${c.clip!.fileName}'),
        //        );
        //        player.resume();
      }
    }
  }

  void setVolume(double volume) {
    _player.setVolume(volume);
    //    for (var player in _players) {
    //      player.setVolume(volume);
    //    }
  }
}
