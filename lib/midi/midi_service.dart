import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'midi_mapping.dart';

enum ConnectionState { disconnected, scanning, connected, error }

class MidiService extends ChangeNotifier {
  final MidiCommand _midi = MidiCommand();
  MidiDevice? _connectedDevice;
  ConnectionState _state = ConnectionState.disconnected;
  String _deviceName = 'No device';

  StreamSubscription? _deviceSub;
  StreamSubscription? _rxSub;
  Function(String type, int channel, int data1, int data2)? onMidiMessage;

  ConnectionState get state => _state;
  String get deviceName => _deviceName;
  bool get isConnected => _state == ConnectionState.connected;

  void startScanning() {
    _state = ConnectionState.scanning;
    notifyListeners();

    _deviceSub = _midi.onMidiSetupChanged?.listen((_) => _refreshDevices());
    _rxSub = _midi.onMidiDataReceived?.listen(_handleIncomingMidi);

    _refreshDevices();
  }

  void _handleIncomingMidi(MidiPacket packet) {
    final Uint8List data = packet.data;
    if (data.isEmpty) return;
    int statusByte = data[0];
    int status = statusByte & 0xF0;
    int channel = (statusByte & 0x0F) + 1;

    if (data.length < 3 && status != 0xD0) return;

    int data1 = data.length > 1 ? data[1] : 0;
    int data2 = data.length > 2 ? data[2] : 0;

    String type = 'unknown';

    switch (status) {
      case 0x90:
        type = (data2 > 0) ? 'noteOn' : 'noteOff';
        if (data2 == 0) type = 'noteOff';
        break;
      case 0x80:
        type = 'noteOff';
        break;
      case 0xB0:
        type = 'controlChange';
        break;
      case 0xE0:
        type = 'pitchBend';
        break;
      default:
        return;
    }

    print('MIDI IN [$type] -> Ch: $channel | Data1: $data1 | Data2: $data2');

    if (onMidiMessage != null) {
      int d1 = data.length > 1 ? data[1] : 0;
      int d2 = data.length > 2 ? data[2] : 0;
      onMidiMessage!(type, channel, d1, d2);
    }
  }

  Future<void> _refreshDevices() async {
    final devices = await _midi.devices ?? [];
    final midiDevices = devices
        .where((d) => d.inputPorts.isNotEmpty || d.outputPorts.isNotEmpty)
        .toList();
    if (midiDevices.isNotEmpty && _connectedDevice == null) {
      await _connect(midiDevices.first);
    } else if (midiDevices.isEmpty && _connectedDevice != null) {
      _connectedDevice = null;
      _state = ConnectionState.disconnected;
      _deviceName = 'No device';
      notifyListeners();
    }
  }

  Future<void> _connect(MidiDevice device) async {
    try {
      _midi.connectToDevice(device);
      _connectedDevice = device;
      _deviceName = device.name;
      _state = ConnectionState.connected;
      print('MIDI: Connected to $_deviceName');
      notifyListeners();
    } catch (e) {
      _state = ConnectionState.error;
      notifyListeners();
    }
  }

  void disconnect() {
    if (_connectedDevice != null) {
      _midi.disconnectDevice(_connectedDevice!);
      _connectedDevice = null;
    }
    _deviceSub?.cancel();
    _rxSub?.cancel();
    _state = ConnectionState.disconnected;
    _deviceName = 'No device';
    notifyListeners();
  }

  void _sendCC(int cc, int value) {
    print('MIDI OUT [CC] -> ID: $cc | Val: $value');
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0xB0 | MidiMapping.channel, cc, value.clamp(0, 127)]),
      deviceId: _connectedDevice?.id,
    );
  }

  void _sendNoteOn(int note, {int velocity = 100}) {
    print('MIDI OUT [NoteOn] -> Note: $note | Vel: $velocity');
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0x90 | MidiMapping.channel, note, velocity]),
      deviceId: _connectedDevice?.id,
    );
  }

  void _sendNoteOff(int note) {
    print('MIDI OUT [NoteOff] -> Note: $note');
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0x80 | MidiMapping.channel, note, 0]),
      deviceId: _connectedDevice?.id,
    );
  }

  void playSlot(int slot) {
    final note = MidiMapping.slotNote(slot);
    _sendNoteOn(note, velocity: 127);

    Future.delayed(const Duration(milliseconds: 100), () {
      _sendNoteOff(note);
    });
  }

  void stopSlot(int slot) {
    _sendCC(MidiMapping.ccStop(slot), 127);
    Future.delayed(const Duration(milliseconds: 50), () {
      _sendCC(MidiMapping.ccStop(slot), 0);
    });
  }

  void generateSlot(int slot) {
    _sendCC(MidiMapping.ccGenerate(slot), 127);
    Future.delayed(const Duration(milliseconds: 150),
        () => _sendCC(MidiMapping.ccGenerate(slot), 0));
  }

  void setVolume(int slot, double value) =>
      _sendCC(MidiMapping.ccVolume(slot), MidiMapping.volumeToMidi(value));

  void setMasterVolume(double value) =>
      _sendCC(MidiMapping.ccMasterVolume, MidiMapping.volumeToMidi(value));

  void setPan(int slot, double value) =>
      _sendCC(MidiMapping.ccPan(slot), MidiMapping.panToMidi(value));

  void setMasterPan(double value) =>
      _sendCC(MidiMapping.ccMasterPan, MidiMapping.panToMidi(value));

  void setMute(int slot, bool muted) =>
      _sendCC(MidiMapping.ccMute(slot), muted ? 127 : 0);

  void setSolo(int slot, bool soloed) =>
      _sendCC(MidiMapping.ccSolo(slot), soloed ? 127 : 0);

  void setPage(int slot, int page) {
    _sendCC(MidiMapping.ccPage(slot), MidiMapping.pageToMidi(page));
  }

  void setPitch(int slot, double semitones) =>
      _sendCC(MidiMapping.ccPitch(slot), MidiMapping.pitchToMidi(semitones));

  void setFine(int slot, double cents) =>
      _sendCC(MidiMapping.ccFine(slot), MidiMapping.fineToMidi(cents));

  void setBeatRepeat(int slot, bool active) =>
      _sendCC(MidiMapping.ccBeatRepeat(slot), active ? 127 : 0);

  void setSeqPattern(int slot, int seqIndex) =>
      _sendCC(MidiMapping.ccSeq(slot), MidiMapping.seqToMidi(seqIndex));

  void nextTrack() {
    _sendCC(MidiMapping.ccNextTrack, 127);
    Future.delayed(const Duration(milliseconds: 100),
        () => _sendCC(MidiMapping.ccNextTrack, 0));
  }

  void prevTrack() {
    _sendCC(MidiMapping.ccPrevTrack, 127);
    Future.delayed(const Duration(milliseconds: 100),
        () => _sendCC(MidiMapping.ccPrevTrack, 0));
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
