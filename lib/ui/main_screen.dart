import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/app_controller.dart';
import '../midi/midi_service.dart';
import 'theme.dart';
import 'widgets/slot_card.dart' show SlotCard;
import 'widgets/controls.dart' show ConnectionBadge;

class ObsidianMainScreen extends StatelessWidget {
  const ObsidianMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();
    final midi = context.watch<MidiService>();

    return Scaffold(
      backgroundColor: ObsidianTheme.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(midi: midi),
            Expanded(
              child: _TracksView(ctrl: ctrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final MidiService midi;
  const _TopBar({required this.midi});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: ObsidianTheme.cardBg,
        border: const Border(
          bottom: BorderSide(color: ObsidianTheme.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text('OBSIDIAN Neural', style: ObsidianTheme.appTitle),
          const SizedBox(width: 6),
          Text('Controller',
              style: ObsidianTheme.labelSmall.copyWith(
                color: ObsidianTheme.textMuted,
              )),
          const Spacer(),
          ListenableBuilder(
            listenable: midi,
            builder: (_, __) => ConnectionBadge(
              isConnected: midi.isConnected,
              deviceName: midi.deviceName,
            ),
          ),
        ],
      ),
    );
  }
}

class _TracksView extends StatelessWidget {
  final AppController ctrl;
  const _TracksView({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: 8,
            itemBuilder: (context, i) {
              final slot = ctrl.slots[i];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SlotCard(
                  slot: slot,
                  isSelected: ctrl.selectedSlot == i,
                  ctrl: ctrl,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
