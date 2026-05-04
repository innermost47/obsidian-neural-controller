import 'package:flutter/foundation.dart';
import '../midi/midi_service.dart';
import '../midi/midi_mapping.dart';
import '../services/preset_service.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  final MidiService midi;

  List<SlotState> _slots = List.generate(8, (i) => SlotState(index: i + 1));
  int _selectedSlot = 0;
  bool get isAnyGenerating => _slots.any((s) => s.isGenerating);
  int get generatingSlot => _slots.indexWhere((s) => s.isGenerating) + 1;
  List<SlotState> get slots => _slots;
  int get selectedSlot => _selectedSlot;
  SlotState get currentSlot => _slots[_selectedSlot];
  String? _currentPresetId;
  String? get currentPresetId => _currentPresetId;
  String? _currentPresetName;
  String? get currentPresetName => _currentPresetName;
  List<double> _pairCrossfaders = List.filled(4, 0.5);
  double _globalCrossfader = 0.5;
  int _crossfaderCurveMode = 1;
  List<double> get pairCrossfaders => _pairCrossfaders;
  double get globalCrossfader => _globalCrossfader;
  int get crossfaderCurveMode => _crossfaderCurveMode;

  AppController({required this.midi}) {
    midi.onMixerFeedback = _handleMixerFeedback;
    midi.onShapingFeedback = _handleShapingFeedback;
    midi.onDeviceConnected = () {
      Future.delayed(const Duration(milliseconds: 500), () {
        midi.requestState();
      });
    };
    midi.startScanning();
  }

  void _handleMixerFeedback(int cc, int value) {
    for (int i = 1; i <= 8; i++) {
      if (cc == MidiMapping.ccFeedbackPlay(i)) {
        if (value == MidiMapping.feedbackIdle)
          _updateSlot(
              i,
              (s) => s.copyWith(
                  isPlaying: false, pendingPlay: false, pendingStop: false));
        else if (value == MidiMapping.feedbackPending)
          _updateSlot(
              i,
              (s) => s.isPlaying
                  ? s.copyWith(pendingStop: true)
                  : s.copyWith(pendingPlay: true));
        else if (value == MidiMapping.feedbackActive)
          _updateSlot(
              i,
              (s) => s.copyWith(
                  isPlaying: true, pendingPlay: false, pendingStop: false));
      }
      if (cc == MidiMapping.ccFeedbackVolume(i)) {
        _updateSlot(i, (s) => s.copyWith(volume: value / 127.0));
      }
      if (cc == MidiMapping.ccFeedbackPan(i)) {
        _updateSlot(i, (s) => s.copyWith(pan: (value / 127.0) * 2.0 - 1.0));
      }
      if (cc == MidiMapping.ccFeedbackMute(i)) {
        _updateSlot(
            i, (s) => s.copyWith(isMuted: value == MidiMapping.feedbackActive));
      }
      if (cc == MidiMapping.ccFeedbackSolo(i)) {
        _updateSlot(
            i, (s) => s.copyWith(isSolo: value == MidiMapping.feedbackActive));
      }
      if (cc == MidiMapping.ccFeedbackGenerate(i)) {
        _updateSlot(i,
            (s) => s.copyWith(isGenerating: value != MidiMapping.feedbackIdle));
        return;
      }
      if (cc == MidiMapping.ccFeedbackPitch(i)) {
        _updateSlot(
            i, (s) => s.copyWith(pitch: (value / 127.0) * 192.0 - 96.0));
      }
      if (cc == MidiMapping.ccFeedbackFine(i)) {
        _updateSlot(
            i, (s) => s.copyWith(fine: (value / 127.0) * 200.0 - 100.0));
      }
      if (cc == MidiMapping.ccFeedbackSeq(i)) {
        _updateSlot(i, (s) => s.copyWith(currentSeq: value));
      }
      if (cc == MidiMapping.ccFeedbackBeatRepeat(i)) {
        _updateSlot(i,
            (s) => s.copyWith(beatRepeat: value == MidiMapping.feedbackActive));
      }
      if (cc == MidiMapping.ccFeedbackPage(i)) {
        if (value == MidiMapping.feedbackPending) {
          _updateSlot(i, (s) => s.copyWith(pendingPage: true));
        } else if (value >= 80 && value <= 83) {
          _updateSlot(
              i,
              (s) => s.copyWith(
                    pendingPage: true,
                    pendingPageTarget: value - 80,
                  ));
        } else {
          _updateSlot(
              i,
              (s) => s.copyWith(
                    currentPage: value,
                    pendingPage: false,
                    pendingPageTarget: -1,
                  ));
        }
        return;
      }
    }
  }

  void _handleShapingFeedback(int cc, int value) {
    for (int i = 0; i < 4; i++) {
      if (cc == MidiMapping.ccFeedbackPairCrossfader(i)) {
        _updatePairCrossfaderState(i, value / 127.0);
        return;
      }
    }
    if (cc == MidiMapping.ccFeedbackGlobalCrossfader) {
      _updateGlobalCrossfaderState(value / 127.0);
      return;
    }
    if (cc == MidiMapping.ccFeedbackCrossfaderCurve) {
      _updateCrossfaderCurveState(value);
      return;
    }
  }

  void _updatePairCrossfaderState(int index, double value) {
    final list = List<double>.from(_pairCrossfaders);
    list[index] = value;
    _pairCrossfaders = list;
    notifyListeners();
  }

  void _updateGlobalCrossfaderState(double value) {
    _globalCrossfader = value;
    notifyListeners();
  }

  void _updateCrossfaderCurveState(int mode) {
    _crossfaderCurveMode = mode.clamp(0, 2);
    notifyListeners();
  }

  void setBeatRepeatHold(int slot, bool active) {
    midi.setBeatRepeat(slot, active);
    _updateSlot(slot, (s) => s.copyWith(beatRepeat: active));
  }

  void syncState() {
    midi.requestState();
  }

  void selectSlot(int index) {
    _selectedSlot = index;
    notifyListeners();
  }

  void playSlot(int slot) {
    midi.playSlot(slot);
  }

  void stopSlot(int slot) {
    midi.stopSlot(slot);
  }

  void generateSlot(int slot) {
    if (isAnyGenerating) return;
    midi.generateSlot(slot);
  }

  void setVolume(int slot, double value) {
    midi.setVolume(slot, value);
    _updateSlot(slot, (s) => s.copyWith(volume: value));
  }

  void setPan(int slot, double value) {
    midi.setPan(slot, value);
    _updateSlot(slot, (s) => s.copyWith(pan: value));
  }

  void setPitch(int slot, double value) {
    midi.setPitch(slot, value);
    _updateSlot(slot, (s) => s.copyWith(pitch: value));
  }

  void setFine(int slot, double value) {
    midi.setFine(slot, value);
    _updateSlot(slot, (s) => s.copyWith(fine: value));
  }

  void toggleMute(int slot) {
    final muted = !_slots[slot - 1].isMuted;
    midi.setMute(slot, muted);
    _updateSlot(slot, (s) => s.copyWith(isMuted: muted));
  }

  void toggleSolo(int slot) {
    final soloed = !_slots[slot - 1].isSolo;
    midi.setSolo(slot, soloed);
    _updateSlot(slot, (s) => s.copyWith(isSolo: soloed));
  }

  void toggleBeatRepeat(int slot) {
    final active = !_slots[slot - 1].beatRepeat;
    midi.setBeatRepeat(slot, active);
    _updateSlot(slot, (s) => s.copyWith(beatRepeat: active));
  }

  void setPage(int slot, int page) {
    if (_slots[slot - 1].isGenerating) return;
    midi.setPage(slot, page);
    _updateSlot(
        slot,
        (s) => s.copyWith(
              currentPage: page,
              pendingPageTarget: page,
            ));
  }

  void setSeq(int slot, int seq) {
    midi.setSeqPattern(slot, seq);
    _updateSlot(slot, (s) => s.copyWith(currentSeq: seq));
  }

  void _updateSlot(int slot, SlotState Function(SlotState) fn) {
    final list = List<SlotState>.from(_slots);
    list[slot - 1] = fn(list[slot - 1]);
    _slots = list;
    notifyListeners();
  }

  void renameSlot(int slot, String name) {
    _updateSlot(slot, (s) => s.copyWith(name: name));
  }

  Future<void> saveCurrentPreset(PresetService service) async {
    if (_currentPresetId == null) return;
    final preset = Preset(
      id: _currentPresetId!,
      name: _currentPresetName!,
      trackNames: _slots.map((s) => s.name).toList(),
    );
    await service.save(preset);
  }

  void loadPreset(Preset preset) {
    for (var j = 0; j < preset.trackNames.length && j < 8; j++) {
      renameSlot(j + 1, preset.trackNames[j]);
    }
    _currentPresetId = preset.id;
    _currentPresetName = preset.name;
    notifyListeners();
  }

  void clearCurrentPreset() {
    _currentPresetId = null;
    _currentPresetName = null;
  }

  void setPairCrossfader(int pairIndex, double value) {
    if (pairIndex < 0 || pairIndex > 3) return;
    midi.setPairCrossfader(pairIndex, value);
    final list = List<double>.from(_pairCrossfaders);
    list[pairIndex] = value;
    _pairCrossfaders = list;
    notifyListeners();
  }

  void setGlobalCrossfader(double value) {
    midi.setGlobalCrossfader(value);
    _globalCrossfader = value;
    notifyListeners();
  }

  void setCrossfaderCurveMode(int mode) {
    final clamped = mode.clamp(0, 2);
    midi.setCrossfaderCurve(clamped);
    _crossfaderCurveMode = clamped;
    notifyListeners();
  }

  @override
  void dispose() {
    midi.dispose();
    super.dispose();
  }
}
