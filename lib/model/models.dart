class SlotState {
  final int index;
  final String name;
  final double volume;
  final double pan;
  final double pitch;
  final double fine;
  final bool isMuted;
  final bool isSolo;
  final bool isPlaying;
  final bool isGenerating;
  final bool beatRepeat;
  final int currentPage;
  final int currentSeq;
  final bool pendingPlay;
  final bool pendingPage;
  final int pendingPageTarget;
  final bool pendingStop;

  const SlotState({
    required this.index,
    this.name = '',
    this.volume = 0.8,
    this.pan = 0.0,
    this.pitch = 0.0,
    this.fine = 0.0,
    this.isMuted = false,
    this.isSolo = false,
    this.isPlaying = false,
    this.isGenerating = false,
    this.beatRepeat = false,
    this.currentPage = 0,
    this.currentSeq = 0,
    this.pendingPlay = false,
    this.pendingPage = false,
    this.pendingPageTarget = -1,
    this.pendingStop = false,
  });

  String get displayName => name.isEmpty ? 'Slot $index' : name;

  SlotState copyWith({
    String? name,
    double? volume,
    double? pan,
    double? pitch,
    double? fine,
    bool? isMuted,
    bool? isSolo,
    bool? isPlaying,
    bool? isGenerating,
    bool? beatRepeat,
    int? currentPage,
    int? currentSeq,
    bool? pendingPlay,
    bool? pendingPage,
    int? pendingPageTarget,
    bool? pendingStop,
  }) =>
      SlotState(
        index: index,
        name: name ?? this.name,
        volume: volume ?? this.volume,
        pan: pan ?? this.pan,
        pitch: pitch ?? this.pitch,
        fine: fine ?? this.fine,
        isMuted: isMuted ?? this.isMuted,
        isSolo: isSolo ?? this.isSolo,
        isPlaying: isPlaying ?? this.isPlaying,
        isGenerating: isGenerating ?? this.isGenerating,
        beatRepeat: beatRepeat ?? this.beatRepeat,
        currentPage: currentPage ?? this.currentPage,
        currentSeq: currentSeq ?? this.currentSeq,
        pendingPlay: pendingPlay ?? this.pendingPlay,
        pendingPage: pendingPage ?? this.pendingPage,
        pendingPageTarget: pendingPageTarget ?? this.pendingPageTarget,
        pendingStop: pendingStop ?? this.pendingStop,
      );
}
