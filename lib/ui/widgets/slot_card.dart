import 'package:flutter/material.dart';
import '../../model/models.dart';
import '../../model/app_controller.dart';
import '../theme.dart';
import 'controls.dart';
import '../../services/haptic.dart';

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
        width: 280,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: ObsidianTheme.cardDecoration(),
        child: SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(slot: slot, midiNote: _midiNote(), ctrl: ctrl),
                    const SizedBox(height: 8),
                    _PageRow(slot: slot, ctrl: ctrl),
                    const SizedBox(height: 6),
                    _SeqRow(slot: slot, ctrl: ctrl),
                    const SizedBox(height: 10),
                    _PlayGenRow(slot: slot, ctrl: ctrl),
                    const SizedBox(height: 12),
                    _BottomRow(slot: slot, ctrl: ctrl),
                    const SizedBox(height: 6),
                    _KnobsRow(slot: slot, ctrl: ctrl),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 32,
                child: ObsidianFader(
                  value: slot.volume,
                  onChanged: (v) => ctrl.setVolume(slot.index, v),
                  label: 'VOL',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnobsRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _KnobsRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ObsidianKnob(
          value: (slot.pan + 1) / 2,
          onChanged: (v) => ctrl.setPan(slot.index, v * 2 - 1),
          size: 34,
          label: 'PAN',
          accentColor: ObsidianTheme.primary,
        ),
        ObsidianKnob(
          value: (slot.pitch + 96) / 192,
          onChanged: (v) => ctrl.setPitch(slot.index, v * 192 - 96),
          size: 34,
          label: 'PITCH',
          accentColor: ObsidianTheme.primaryLight,
        ),
        ObsidianKnob(
          value: (slot.fine + 100) / 200,
          onChanged: (v) => ctrl.setFine(slot.index, v * 200 - 100),
          size: 34,
          label: 'FINE',
          accentColor: ObsidianTheme.primaryLight,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final SlotState slot;
  final String midiNote;
  final AppController ctrl;

  const _Header({
    required this.slot,
    required this.midiNote,
    required this.ctrl,
  });

  void _showRenameDialog(BuildContext context) {
    final textCtrl = TextEditingController(text: slot.name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ObsidianTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rename', style: ObsidianTheme.slotTitle),
            const SizedBox(height: 12),
            TextField(
              controller: textCtrl,
              autofocus: true,
              maxLength: 20,
              style: ObsidianTheme.slotTitle,
              decoration: InputDecoration(
                hintText: 'Track ${slot.index}',
                hintStyle: ObsidianTheme.labelSmall
                    .copyWith(color: ObsidianTheme.textMuted),
                counterStyle: ObsidianTheme.labelTiny
                    .copyWith(color: ObsidianTheme.textMuted),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ObsidianTheme.border)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: ObsidianTheme.primary)),
              ),
              onSubmitted: (v) {
                ctrl.renameSlot(slot.index, v.trim());
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel',
                      style: ObsidianTheme.labelSmall
                          .copyWith(color: ObsidianTheme.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    ctrl.renameSlot(slot.index, textCtrl.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: Text('OK',
                      style: ObsidianTheme.labelSmall
                          .copyWith(color: ObsidianTheme.primary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRenameDialog(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(slot.displayName, style: ObsidianTheme.slotTitle),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.edit_outlined,
                  size: 10,
                  color: ObsidianTheme.textMuted,
                ),
              ],
            ),
          ),
          Text(midiNote, style: ObsidianTheme.noteLabel),
        ],
      ),
    );
  }
}

class _PageRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _PageRow({required this.slot, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final isDisabled = slot.isGenerating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAGE', style: ObsidianTheme.labelTiny),
        const SizedBox(height: 3),
        Opacity(
          opacity: isDisabled ? 0.3 : 1.0,
          child: Row(
            children: List.generate(4, (i) {
              final label = ['A', 'B', 'C', 'D'][i];
              final isPendingTarget =
                  slot.pendingPage && slot.pendingPageTarget == i;
              final isCurrent = slot.currentPage == i && !slot.pendingPage;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 3 : 0),
                  child: isPendingTarget
                      ? _PendingPagePill(
                          label: label,
                          color: ObsidianTheme.pageColors[i],
                          onTap: isDisabled
                              ? () {}
                              : () => ctrl.setPage(slot.index, i),
                        )
                      : ObsidianPill(
                          label: label,
                          active: isCurrent,
                          onTap: isDisabled
                              ? () {}
                              : () => ctrl.setPage(slot.index, i),
                          activeColor: ObsidianTheme.pageColors[i],
                          size: 26,
                        ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _PendingPagePill extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PendingPagePill(
      {required this.label, required this.color, required this.onTap});

  @override
  State<_PendingPagePill> createState() => _PendingPagePillState();
}

class _PendingPagePillState extends State<_PendingPagePill>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.2, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        Haptic.light();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Container(
          height: 26,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_pulse.value),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: widget.color),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: ObsidianTheme.labelTiny.copyWith(
                color: ObsidianTheme.textOnPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SeqRow extends StatelessWidget {
  final SlotState slot;
  final AppController ctrl;
  const _SeqRow({required this.slot, required this.ctrl});

  Widget _seqPad(int i) {
    return GestureDetector(
      onTapDown: (_) {
        Haptic.light();
        ctrl.setSeq(slot.index, i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 30,
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
            height: 32,
            child: ObsidianActionButton(
              idleIcon: Icons.play_arrow,
              activeIcon: Icons.stop,
              pendingIcon: slot.pendingStop ? Icons.stop : Icons.play_arrow,
              state: slot.pendingPlay
                  ? ActionState.pending
                  : slot.pendingStop
                      ? ActionState.pending
                      : slot.isPlaying
                          ? ActionState.active
                          : ActionState.idle,
              onTap: () => ctrl.playSlot(slot.index),
              activeColor: ObsidianTheme.primary,
              size: 44,
              tooltip: 'Play',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 32,
            child: GenerateButton(
              isGenerating: slot.isGenerating,
              isDisabled: !slot.isGenerating && ctrl.isAnyGenerating,
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
          child: GestureDetector(
            onTapDown: (_) {
              Haptic.light();
              ctrl.setBeatRepeatHold(slot.index, true);
            },
            onTapUp: (_) => ctrl.setBeatRepeatHold(slot.index, false),
            onTapCancel: () => ctrl.setBeatRepeatHold(slot.index, false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: slot.beatRepeat
                    ? ObsidianTheme.beatRepeatOn
                    : ObsidianTheme.cardBg,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: slot.beatRepeat
                      ? ObsidianTheme.beatRepeatOn
                      : ObsidianTheme.border,
                ),
              ),
              child: Center(
                child: Text(
                  '↻',
                  style: ObsidianTheme.labelTiny.copyWith(
                    color: slot.beatRepeat
                        ? ObsidianTheme.textOnPrimary
                        : ObsidianTheme.textSecondary,
                    fontWeight:
                        slot.beatRepeat ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
