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
  Function(int cc, int value)? onMixerFeedback;
  Function(int cc, int value)? onShapingFeedback;
  Function()? onDeviceConnected;

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

  void requestState() {
    _sendCC(MidiMapping.ccRequestState, 127, MidiMapping.channelPerf);
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
    if (status == 0xB0) {
      if (channel == MidiMapping.feedbackChannelMixer + 1) {
        onMixerFeedback?.call(data1, data2);
        return;
      } else if (channel == MidiMapping.feedbackChannelShaping + 1) {
        onShapingFeedback?.call(data1, data2);
        return;
      }
    }
    String type = 'unknown';
    switch (status) {
      case 0x90:
        type = (data2 > 0) ? 'noteOn' : 'noteOff';
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
    onMidiMessage?.call(type, channel, data1, data2);
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
      notifyListeners();
      onDeviceConnected?.call();
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

  void _sendCC(int cc, int value, int channel) {
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0xB0 | channel, cc, value.clamp(0, 127)]),
      deviceId: _connectedDevice?.id,
    );
  }

  void _sendNoteOn(int note, int channel, {int velocity = 100}) {
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0x90 | channel, note, velocity]),
      deviceId: _connectedDevice?.id,
    );
  }

  void _sendNoteOff(int note, int channel) {
    if (!isConnected) return;
    _midi.sendData(
      Uint8List.fromList([0x80 | channel, note, 0]),
      deviceId: _connectedDevice?.id,
    );
  }

  void playSlot(int slot) {
    final note = MidiMapping.slotNote(slot);
    _sendNoteOn(note, MidiMapping.channelPerf, velocity: 127);

    Future.delayed(const Duration(milliseconds: 100), () {
      _sendNoteOff(note, MidiMapping.channelPerf);
    });
  }

  void stopSlot(int slot) {
    _sendCC(MidiMapping.ccStop(slot), 127, MidiMapping.channelPerf);
    Future.delayed(const Duration(milliseconds: 50), () {
      _sendCC(MidiMapping.ccStop(slot), 0, MidiMapping.channelPerf);
    });
  }

  void generateSlot(int slot) {
    _sendCC(MidiMapping.ccGenerate(slot), 127, MidiMapping.channelPerf);
    Future.delayed(
        const Duration(milliseconds: 150),
        () =>
            _sendCC(MidiMapping.ccGenerate(slot), 0, MidiMapping.channelPerf));
  }

  void setVolume(int slot, double value) => _sendCC(MidiMapping.ccVolume(slot),
      MidiMapping.volumeToMidi(value), MidiMapping.channelPerf);

  void setMasterVolume(double value) => _sendCC(MidiMapping.ccMasterVolume,
      MidiMapping.volumeToMidi(value), MidiMapping.channelPerf);

  void setPan(int slot, double value) => _sendCC(MidiMapping.ccPan(slot),
      MidiMapping.panToMidi(value), MidiMapping.channelPerf);

  void setMasterPan(double value) => _sendCC(MidiMapping.ccMasterPan,
      MidiMapping.panToMidi(value), MidiMapping.channelPerf);

  void setMute(int slot, bool muted) => _sendCC(
      MidiMapping.ccMute(slot), muted ? 127 : 0, MidiMapping.channelPerf);

  void setSolo(int slot, bool soloed) => _sendCC(
      MidiMapping.ccSolo(slot), soloed ? 127 : 0, MidiMapping.channelPerf);

  void nextTrack() {
    _sendCC(MidiMapping.ccNextTrack, 127, MidiMapping.channelPerf);
    Future.delayed(const Duration(milliseconds: 100),
        () => _sendCC(MidiMapping.ccNextTrack, 0, MidiMapping.channelPerf));
  }

  void prevTrack() {
    _sendCC(MidiMapping.ccPrevTrack, 127, MidiMapping.channelPerf);
    Future.delayed(const Duration(milliseconds: 100),
        () => _sendCC(MidiMapping.ccPrevTrack, 0, MidiMapping.channelPerf));
  }

  void setPitch(int slot, double semitones) => _sendCC(
      MidiMapping.ccPitch(slot),
      MidiMapping.pitchToMidi(semitones),
      MidiMapping.channelShape);

  void setFine(int slot, double cents) => _sendCC(MidiMapping.ccFine(slot),
      MidiMapping.fineToMidi(cents), MidiMapping.channelShape);

  void setAdsrAttack(int slot, double normalized) => _sendCC(
      MidiMapping.ccAdsrAttack(slot),
      (normalized * 127).round().clamp(0, 127),
      MidiMapping.channelShape);

  void setAdsrDecay(int slot, double normalized) => _sendCC(
      MidiMapping.ccAdsrDecay(slot),
      (normalized * 127).round().clamp(0, 127),
      MidiMapping.channelShape);

  void setAdsrSustain(int slot, double normalized) => _sendCC(
      MidiMapping.ccAdsrSustain(slot),
      (normalized * 127).round().clamp(0, 127),
      MidiMapping.channelShape);

  void setAdsrRelease(int slot, double normalized) => _sendCC(
      MidiMapping.ccAdsrRelease(slot),
      (normalized * 127).round().clamp(0, 127),
      MidiMapping.channelShape);

  void setBeatRepeat(int slot, bool active) => _sendCC(
      MidiMapping.ccBeatRepeat(slot),
      active ? 127 : 0,
      MidiMapping.channelShape);

  void setPage(int slot, int page) {
    _sendCC(MidiMapping.ccPage(slot), MidiMapping.pageToMidi(page),
        MidiMapping.channelShape);
  }

  void setSeqPattern(int slot, int seqIndex) => _sendCC(MidiMapping.ccSeq(slot),
      MidiMapping.seqToMidi(seqIndex), MidiMapping.channelShape);

  void setPairCrossfader(int pairIndex, double value) {
    final cc = pairIndex == 0
        ? MidiMapping.ccPairCrossfader1
        : pairIndex == 1
            ? MidiMapping.ccPairCrossfader2
            : pairIndex == 2
                ? MidiMapping.ccPairCrossfader3
                : MidiMapping.ccPairCrossfader4;
    _sendCC(cc, MidiMapping.volumeToMidi(value), MidiMapping.channelXfader);
  }

  void setGlobalCrossfader(double value) => _sendCC(
      MidiMapping.ccGlobalCrossfader,
      MidiMapping.volumeToMidi(value),
      MidiMapping.channelXfader);

  void setCrossfaderCurve(int curveIndex) {
    final value = (curveIndex.clamp(0, 2) * 63).clamp(0, 127);
    _sendCC(MidiMapping.ccCrossfaderCurve, value, MidiMapping.channelXfader);
  }

  void setMasterHigh(double db) {
    final value = (((db + 12.0) / 24.0) * 127).round().clamp(0, 127);
    _sendCC(MidiMapping.ccMasterHigh, value, MidiMapping.channelXfader);
  }

  void setMasterMid(double db) {
    final value = (((db + 12.0) / 24.0) * 127).round().clamp(0, 127);
    _sendCC(MidiMapping.ccMasterMid, value, MidiMapping.channelXfader);
  }

  void setMasterLow(double db) {
    final value = (((db + 12.0) / 24.0) * 127).round().clamp(0, 127);
    _sendCC(MidiMapping.ccMasterLow, value, MidiMapping.channelXfader);
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
