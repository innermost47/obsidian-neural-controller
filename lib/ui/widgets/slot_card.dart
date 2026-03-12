import 'package:flutter/material.dart';
import '../../model/models.dart';
import '../../model/app_controller.dart';
import '../theme.dart';
import 'controls.dart';

class SlotCard extends StatelessWidget {
  final SlotState slot;
  final bool isSelected;
  final AppController ctrl;

  const SlotCard({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.ctrl,
  });

  String _midiNote() {
    const names = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B'
    ];
    final note = 59 + slot.index;
    return '${names[note % 12]}${note ~/ 12 - 1}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 190,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: ObsidianTheme.cardDecoration(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(slot: slot, midiNote: _midiNote()),
              const SizedBox(height: 8),
              _PageRow(slot: slot, ctrl: ctrl),
              const SizedBox(height: 8),
              _SeqRow(slot: slot, ctrl: ctrl),
              const SizedBox(height: 10),
              _PlayGenRow(slot: slot, ctrl: ctrl),
              const SizedBox(height: 6),
              _BottomRow(slot: slot, ctrl: ctrl),
              const SizedBox(height: 8),
              _VolumeAndPan(slot: slot, ctrl: ctrl),
              const SizedBox(height: 10),
              _PitchRow(slot: slot, ctrl: ctrl),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SlotState slot;
  final String midiNote;
  const _Header({required this.slot, required this.midiNote});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(slot.displayName, style: ObsidianTheme.slotTitle),
        Text(midiNote, style: ObsidianTheme.noteLabel),
      ],
    );
  }
}

class _PageRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _PageRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAGE', style: ObsidianTheme.labelTiny),
        const SizedBox(height: 3),
        Row(
          children: List.generate(4, (i) {
            final label = ['A', 'B', 'C', 'D'][i];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 3 : 0),
                child: ObsidianPill(
                  label: label,
                  active: slot.currentPage == i,
                  onTap: () => ctrl.setPage(slot.index, i),
                  activeColor: ObsidianTheme.pageColors[i],
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SeqRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _SeqRow({required this.slot, required this.ctrl});

  Widget _seqPad(int i) {
    return GestureDetector(
      onTap: () => ctrl.setSeq(slot.index, i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 36,
        decoration: BoxDecoration(
          color: slot.currentSeq == i
              ? ObsidianTheme.primary
              : ObsidianTheme.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: slot.currentSeq == i
                ? ObsidianTheme.primary
                : ObsidianTheme.border,
          ),
        ),
        child: Center(
          child: Text(
            '${i + 1}',
            style: ObsidianTheme.labelSmall.copyWith(
              color: slot.currentSeq == i
                  ? ObsidianTheme.textOnPrimary
                  : ObsidianTheme.textMuted,
              fontWeight:
                  slot.currentSeq == i ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SEQ', style: ObsidianTheme.labelTiny),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
              4,
              (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 3 : 0),
                      child: _seqPad(i),
                    ),
                  )),
        ),
        const SizedBox(height: 3),
        Row(
          children: List.generate(
              4,
              (i) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 3 ? 3 : 0),
                      child: _seqPad(i + 4),
                    ),
                  )),
        ),
      ],
    );
  }
}

class _VolumeAndPan extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _VolumeAndPan({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ObsidianFader(
          value: slot.volume,
          onChanged: (v) => ctrl.setVolume(slot.index, v),
          height: 90,
          label: 'VOL',
        ),
        ObsidianKnob(
          value: (slot.pan + 1) / 2,
          onChanged: (v) => ctrl.setPan(slot.index, v * 2 - 1),
          size: 40,
          label: 'PAN',
          accentColor: ObsidianTheme.primary,
        ),
      ],
    );
  }
}

class _PitchRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _PitchRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ObsidianKnob(
          value: (slot.pitch + 12) / 24,
          onChanged: (v) => ctrl.setPitch(slot.index, v * 24 - 12),
          size: 38,
          label: 'PITCH',
          accentColor: ObsidianTheme.primaryLight,
        ),
        ObsidianKnob(
          value: (slot.fine + 50) / 100,
          onChanged: (v) => ctrl.setFine(slot.index, v * 100 - 50),
          size: 38,
          label: 'FINE',
          accentColor: ObsidianTheme.primaryLight,
        ),
      ],
    );
  }
}

class _PlayGenRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _PlayGenRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: ObsidianIconBtn(
              icon: Icons.play_arrow,
              active: slot.isPlaying,
              onTap: () => ctrl.playSlot(slot.index),
              activeColor: ObsidianTheme.primary,
              size: 28,
              tooltip: 'Play',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 44,
            child: GenerateButton(
              isGenerating: slot.isGenerating,
              onTap: () => ctrl.generateSlot(slot.index),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _BottomRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ObsidianPill(
            label: 'M',
            active: slot.isMuted,
            onTap: () => ctrl.toggleMute(slot.index),
            activeColor: ObsidianTheme.muteActive,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ObsidianPill(
            label: 'S',
            active: slot.isSolo,
            onTap: () => ctrl.toggleSolo(slot.index),
            activeColor: ObsidianTheme.soloActive,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ObsidianPill(
            label: '↻',
            active: slot.beatRepeat,
            onTap: () => ctrl.toggleBeatRepeat(slot.index),
            activeColor: ObsidianTheme.beatRepeatOn,
          ),
        ),
      ],
    );
  }
}
