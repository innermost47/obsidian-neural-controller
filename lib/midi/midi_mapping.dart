class MidiMapping {
  static const int channel = 0;
  static int slotNote(int slot) => 35 + slot;
  static const int ccMasterVolume = 7;
  static const int ccMasterPan = 10;
  static int ccVolume(int slot) => 19 + slot;
  static int ccPan(int slot) => 29 + slot;
  static int ccMute(int slot) => 39 + slot;
  static int ccSolo(int slot) => 49 + slot;
  static int ccGenerate(int slot) => 59 + slot;
  static int ccStop(int slot) => 69 + slot;
  static const int ccNextTrack = 80;
  static const int ccPrevTrack = 81;
  static int ccPage(int slot) => 89 + slot;
  static int ccPitch(int slot) => 99 + slot;
  static int ccFine(int slot) => 109 + slot;
  static int ccBeatRepeat(int slot) => 119 + slot;
  static int ccSeq(int slot) => 15 + slot;

  static const int feedbackChannel = 1;
  static const int feedbackIdle = 0;
  static const int feedbackPending = 64;
  static const int feedbackActive = 127;

  static int ccFeedbackPlay(int slot) => 20 + slot;
  static int ccFeedbackGenerate(int slot) => 30 + slot;
  static int ccFeedbackPage(int slot) => 40 + slot;

  static int pageToMidi(int pageIndex) {
    if (pageIndex == 0) return 10;
    if (pageIndex == 1) return 45;
    if (pageIndex == 2) return 75;
    if (pageIndex == 3) return 110;
    return 0;
  }

  static int pitchToMidi(double pitch) =>
      ((pitch + 12.0) / 24.0 * 127).round().clamp(0, 127);
  static int fineToMidi(double fine) =>
      ((fine + 50.0) / 100.0 * 127).round().clamp(0, 127);
  static int volumeToMidi(double v) => (v * 127).round().clamp(0, 127);
  static int panToMidi(double pan) =>
      ((pan + 1.0) / 2.0 * 127).round().clamp(0, 127);
  static int seqToMidi(int seq) => (seq * 18).clamp(0, 127);
}
