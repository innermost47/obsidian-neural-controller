// lib/model/models.dart

class SlotState {
  final int index; // 1-based
  final String name;
  final double volume; // 0..1
  final double pan; // -1..1
  final double pitch; // -12..+12 semitones
  final double fine; // -50..+50 cents
  final bool isMuted;
  final bool isSolo;
  final bool isPlaying;
  final bool isGenerating;
  final bool beatRepeat;
  final int currentPage; // 0=A, 1=B, 2=C, 3=D
  final int currentSeq; // 0-7 (Seq1..Seq8)

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
  }) => SlotState(
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
  );
}

class MasterState {
  final double volume;
  final double pan;

  const MasterState({this.volume = 0.8, this.pan = 0.0});

  MasterState copyWith({double? volume, double? pan}) =>
      MasterState(volume: volume ?? this.volume, pan: pan ?? this.pan);
}
