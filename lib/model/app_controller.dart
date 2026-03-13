import 'package:flutter/foundation.dart';
import '../midi/midi_service.dart';
import '../midi/midi_mapping.dart';
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

  AppController({required this.midi}) {
    midi.onFeedbackMessage = _handleFeedback;
    midi.onDeviceConnected = () {
      Future.delayed(const Duration(milliseconds: 500), () {
        midi.requestState();
      });
    };
    midi.startScanning();
  }

  void _handleFeedback(int cc, int value) {
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
                  ? s.copyWith(pendingStop: true, pendingPlay: false)
                  : s.copyWith(pendingPlay: true, pendingStop: false));
        else if (value == MidiMapping.feedbackActive)
          _updateSlot(
              i,
              (s) => s.copyWith(
                  isPlaying: true, pendingPlay: false, pendingStop: false));
      }
      if (cc == MidiMapping.ccFeedbackGenerate(i)) {
        _updateSlot(i,
            (s) => s.copyWith(isGenerating: value != MidiMapping.feedbackIdle));
        return;
      }
      if (cc == MidiMapping.ccFeedbackPage(i)) {
        if (value == MidiMapping.feedbackPending) {
          _updateSlot(i, (s) => s.copyWith(pendingPage: true));
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
      if (cc == MidiMapping.ccFeedbackVolume(i)) {
        _updateSlot(i, (s) => s.copyWith(volume: value / 127.0));
        return;
      }
      if (cc == MidiMapping.ccFeedbackPan(i)) {
        _updateSlot(i, (s) => s.copyWith(pan: (value / 127.0) * 2.0 - 1.0));
        return;
      }
      if (cc == MidiMapping.ccFeedbackPitch(i)) {
        _updateSlot(
            i, (s) => s.copyWith(pitch: (value / 127.0) * 192.0 - 96.0));
        return;
      }
      if (cc == MidiMapping.ccFeedbackFine(i)) {
        _updateSlot(
            i, (s) => s.copyWith(fine: (value / 127.0) * 200.0 - 100.0));
        return;
      }
      if (cc == MidiMapping.ccFeedbackMute(i)) {
        _updateSlot(
            i, (s) => s.copyWith(isMuted: value == MidiMapping.feedbackActive));
        return;
      }
      if (cc == MidiMapping.ccFeedbackSolo(i)) {
        _updateSlot(
            i, (s) => s.copyWith(isSolo: value == MidiMapping.feedbackActive));
        return;
      }
      if (cc == MidiMapping.ccFeedbackBeatRepeat(i)) {
        _updateSlot(i,
            (s) => s.copyWith(beatRepeat: value == MidiMapping.feedbackActive));
        return;
      }
      if (cc == MidiMapping.ccFeedbackSeq(i)) {
        _updateSlot(i, (s) => s.copyWith(currentSeq: value));
        return;
      }
    }
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

  @override
  void dispose() {
    midi.dispose();
    super.dispose();
  }
}
