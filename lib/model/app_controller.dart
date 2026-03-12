import 'dart:async';
import 'package:flutter/foundation.dart';
import '../midi/midi_service.dart';
import 'models.dart';

class AppController extends ChangeNotifier {
  final MidiService midi;

  List<SlotState> _slots = List.generate(8, (i) => SlotState(index: i + 1));
  MasterState _master = const MasterState();
  int _selectedSlot = 0;

  List<SlotState> get slots => _slots;
  MasterState get master => _master;
  int get selectedSlot => _selectedSlot;
  SlotState get currentSlot => _slots[_selectedSlot];

  AppController({required this.midi}) {
    midi.startScanning();
  }

  void selectSlot(int index) {
    _selectedSlot = index;
    notifyListeners();
  }

  void playSlot(int slot) {
    midi.playSlot(slot);
    _updateSlot(slot, (s) => s.copyWith(isPlaying: true));
  }

  void stopSlot(int slot) {
    midi.stopSlot(slot);
    _updateSlot(slot, (s) => s.copyWith(isPlaying: false));
  }

  void generateSlot(int slot) {
    midi.generateSlot(slot);
    _updateSlot(slot, (s) => s.copyWith(isGenerating: true));
    Future.delayed(
      const Duration(milliseconds: 500),
      () => _updateSlot(slot, (s) => s.copyWith(isGenerating: false)),
    );
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
    midi.setPage(slot, page);
    _updateSlot(slot, (s) => s.copyWith(currentPage: page));
  }

  void setSeq(int slot, int seq) {
    midi.setSeqPattern(slot, seq);
    _updateSlot(slot, (s) => s.copyWith(currentSeq: seq));
  }

  void setMasterVolume(double value) {
    midi.setMasterVolume(value);
    _master = _master.copyWith(volume: value);
    notifyListeners();
  }

  void setMasterPan(double value) {
    midi.setMasterPan(value);
    _master = _master.copyWith(pan: value);
    notifyListeners();
  }

  void nextTrack() => midi.nextTrack();
  void prevTrack() => midi.prevTrack();

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
