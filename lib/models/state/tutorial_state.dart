import 'package:elevate/models/agent.dart';
import 'package:elevate/models/state/tech_tree_state.dart';
import 'package:flutter/foundation.dart';

enum TutorialStage {
  elevators1Controls,
  elevators2Transport10,
  elevators3TechTree,
  elevators4Destinations,
  elevators5Late,
  finalNotes,
  done
  ;

  TutorialStage? get next {
    return switch (this) {
      TutorialStage.elevators1Controls => TutorialStage.elevators2Transport10,
      TutorialStage.elevators2Transport10 => TutorialStage.elevators3TechTree,
      TutorialStage.elevators3TechTree => TutorialStage.elevators4Destinations,
      TutorialStage.elevators4Destinations => TutorialStage.elevators5Late,
      TutorialStage.elevators5Late => TutorialStage.finalNotes,
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
    _stage = .elevators1Controls;
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
    if (_stage == .elevators1Controls) {
      _stage = .elevators2Transport10;
      _counter = 0;
      notifyListeners();
    } else if (_stage == .elevators2Transport10) {
      _counter += 1;
      if (_counter >= 10) {
        _stage = .elevators3TechTree;
        _counter = 0;
      }
      // Has progress info => notify on each recorded transport
      notifyListeners();
    } else if (_stage == .elevators4Destinations) {
      if (targetLvl >= 1 && targetLvl <= 2) {
        _counter = _counter | targetLvl;
        if (_counter == (1 | 2)) {
          _stage = .elevators5Late;
          _counter = 0;
        }
        // Has progress info => notify on each recorded transport
        notifyListeners();
      }
    } else if (_stage == .elevators5Late) {
      if (lateness != .neutral) {
        _stage = .finalNotes;
        _counter = 0;
        notifyListeners();
      }
    }
  }

  void recordTechUpgrade(TechId id) {
    if (_stage == .elevators3TechTree) {
      _stage = .elevators4Destinations;
      notifyListeners();
    }
  }

  int transportedObjectiveProgress() {
    if (_stage == .elevators2Transport10) {
      return _counter;
    } else if (_stage == .elevators4Destinations) {
      int n = 0;
      n += (_counter & 1) != 0 ? 1 : 0;
      n += (_counter & 2) != 0 ? 1 : 0;
      return n;
    }
    return 0;
  }

  void update(double elapsed) {}
}
