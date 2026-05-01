class MidiMapping {
  static const int channelPerf = 0;
  static const int channelShape = 1;
  static const int channelXfader = 2;
  static const int ccMasterVolume = 7;
  static const int ccMasterPan = 10;
  static int slotNote(int slot) => 35 + slot;
  static int ccVolume(int slot) => 19 + slot;
  static int ccPan(int slot) => 29 + slot;
  static int ccMute(int slot) => 39 + slot;
  static int ccSolo(int slot) => 49 + slot;
  static int ccGenerate(int slot) => 59 + slot;
  static int ccPitch(int slot) => 19 + slot;
  static int ccFine(int slot) => 29 + slot;
  static int ccAdsrAttack(int slot) => 39 + slot;
  static int ccAdsrDecay(int slot) => 49 + slot;
  static int ccAdsrSustain(int slot) => 59 + slot;
  static int ccAdsrRelease(int slot) => 69 + slot;
  static int ccBeatRepeat(int slot) => 79 + slot;
  static int ccPage(int slot) => 89 + slot;
  static int ccSeq(int slot) => 99 + slot;
  static const int ccPairCrossfader1 = 20;
  static const int ccPairCrossfader2 = 21;
  static const int ccPairCrossfader3 = 22;
  static const int ccPairCrossfader4 = 23;
  static const int ccGlobalCrossfader = 24;
  static const int ccCrossfaderCurve = 25;
  static const int ccMasterHigh = 26;
  static const int ccMasterMid = 27;
  static const int ccMasterLow = 28;
  static int pageToMidi(int pageIndex) {
    if (pageIndex == 0) return 10;
    if (pageIndex == 1) return 45;
    if (pageIndex == 2) return 75;
    if (pageIndex == 3) return 110;
    return 0;
  }

  static int pitchToMidi(double pitch) =>
      ((pitch + 96.0) / 192.0 * 127).round().clamp(0, 127);
  static int fineToMidi(double fine) =>
      ((fine + 50.0) / 100.0 * 127).round().clamp(0, 127);
  static int volumeToMidi(double v) => (v * 127).round().clamp(0, 127);
  static int panToMidi(double pan) =>
      ((pan + 1.0) / 2.0 * 127).round().clamp(0, 127);
  static int seqToMidi(int seq) => (seq * 18).clamp(0, 127);
  static int ccStop(int slot) => 69 + slot;
  static const int ccNextTrack = 80;
  static const int ccPrevTrack = 81;
  static const int ccRequestState = 118;

  static const int feedbackChannelMixer = 3;
  static const int feedbackChannelShaping = 4;

  static const int feedbackIdle = 0;
  static const int feedbackPending = 64;
  static const int feedbackActive = 127;

  static int ccFeedbackPlay(int slot) => 20 + slot;
  static int ccFeedbackGenerate(int slot) => 30 + slot;
  static int ccFeedbackPage(int slot) => 40 + slot;
  static int ccFeedbackVolume(int slot) => 50 + slot;
  static int ccFeedbackPan(int slot) => 60 + slot;
  static int ccFeedbackPitch(int slot) => 70 + slot;
  static int ccFeedbackFine(int slot) => 80 + slot;
  static int ccFeedbackSeq(int slot) => 90 + slot;
  static int ccFeedbackMute(int slot) => 100 + slot;
  static int ccFeedbackSolo(int slot) => 110 + slot;
  static int ccFeedbackBeatRepeat(int slot) => 118 + slot;

  static int ccFeedbackAdsrAttack(int slot) => 20 + slot;
  static int ccFeedbackAdsrDecay(int slot) => 30 + slot;
  static int ccFeedbackAdsrSustain(int slot) => 40 + slot;
  static int ccFeedbackAdsrRelease(int slot) => 50 + slot;
  static int ccFeedbackPairCrossfader(int pair) => 59 + pair;
  static const int ccFeedbackGlobalCrossfader = 64;
  static const int ccFeedbackCrossfaderCurve = 65;
  static const int ccFeedbackMasterHigh = 66;
  static const int ccFeedbackMasterMid = 67;
  static const int ccFeedbackMasterLow = 68;
}
