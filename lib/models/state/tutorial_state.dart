import 'package:elevate/models/agent.dart';
import 'package:flutter/foundation.dart';

enum TutorialStage {
  elevators1(1),
  elevators2(2),
  elevators3(3),
  elevators4(4),
  finalNotes(99),
  done(100)
  ;

  const TutorialStage(this.value);

  final int value;

  TutorialStage? get next {
    return switch (this) {
      TutorialStage.elevators1 => TutorialStage.elevators2,
      TutorialStage.elevators2 => TutorialStage.elevators3,
      TutorialStage.elevators3 => TutorialStage.elevators4,
      TutorialStage.elevators4 => TutorialStage.finalNotes,
      TutorialStage.finalNotes => TutorialStage.done,
      TutorialStage.done => null,
    };
  }
}

class TutorialState extends ChangeNotifier {
  late TutorialStage _stage;
  late int _counter;

  TutorialState() {
    reset();
  }

  reset() {
    _stage = .elevators1;
    _counter = 0;
  }

  TutorialStage get stage => _stage;
  set stage(TutorialStage value) {
    if (value != _stage) {
      _stage = value;
      notifyListeners();
    }
  }

  void recordTransported(AgentLateness lateness, int targetLvl) {
    if (_stage == .elevators1) {
      _stage = .elevators2;
      _counter = 0;
      notifyListeners();
    } else if (_stage == .elevators2) {
      _counter += 1;
      if (_counter >= 10) {
        _stage = .elevators3;
        _counter = 0;
      }
      // Has progress info => notify on each recorded transport
      notifyListeners();
    } else if (_stage == .elevators3) {
      if (targetLvl >= 1 && targetLvl <= 2) {
        _counter = _counter | targetLvl;
        if (_counter == (1 | 2)) {
          _stage = .elevators4;
          _counter = 0;
        }
        // Has progress info => notify on each recorded transport
        notifyListeners();
      }
    } else if (_stage == .elevators4) {
      if (lateness != .neutral) {
        _stage = .finalNotes;
        _counter = 0;
        notifyListeners();
      }
    }
  }

  int transportedObjectiveProgress() {
    if (_stage == .elevators2) {
      return _counter;
    } else if (_stage == .elevators3) {
      int n = 0;
      n += (_counter & 1) != 0 ? 1 : 0;
      n += (_counter & 2) != 0 ? 1 : 0;
      return n;
    }
    return 0;
  }

  void update(double elapsed) {}
}
