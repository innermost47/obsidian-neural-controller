import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../model/app_controller.dart';
import '../midi/midi_service.dart' hide ConnectionState;
import '../services/preset_service.dart';
import 'theme.dart';
import 'widgets/crossfader_panel.dart';
import 'widgets/slot_card.dart' show SlotCard;
import 'widgets/controls.dart' show ConnectionBadge;

class ObsidianMainScreen extends StatelessWidget {
  const ObsidianMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();
    final midi = context.watch<MidiService>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ObsidianTheme.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(midi: midi, ctrl: ctrl),
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
  final AppController ctrl;
  const _TopBar({required this.midi, required this.ctrl});

  void _showSaveSheet(BuildContext context) {
    final service = PresetService();
    final hasCurrentPreset = ctrl.currentPresetId != null;

    if (hasCurrentPreset) {
      showModalBottomSheet(
        context: context,
        backgroundColor: ObsidianTheme.cardBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save', style: ObsidianTheme.slotTitle),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 16),
                  label: Text('Overwrite "${ctrl.currentPresetName}"'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primary,
                    foregroundColor: ObsidianTheme.textOnPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await ctrl.saveCurrentPreset(service);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Preset "${ctrl.currentPresetName}" saved'),
                      backgroundColor: ObsidianTheme.primary,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_as_outlined, size: 16),
                  label: const Text('Save as...'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ObsidianTheme.primary,
                    side: BorderSide(
                        color: ObsidianTheme.primary.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showSaveAsSheet(context, service);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      _showSaveAsSheet(context, service);
    }
  }

  void _showSaveAsSheet(BuildContext context, PresetService service) {
    final nameCtrl = TextEditingController();
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New preset', style: ObsidianTheme.slotTitle),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                maxLength: 30,
                style: ObsidianTheme.slotTitle,
                decoration: InputDecoration(
                  hintText: 'Preset name...',
                  hintStyle: ObsidianTheme.labelSmall
                      .copyWith(color: ObsidianTheme.textMuted),
                  counterStyle: ObsidianTheme.labelTiny
                      .copyWith(color: ObsidianTheme.textMuted),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ObsidianTheme.border)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: ObsidianTheme.primary)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ObsidianTheme.primary,
                    foregroundColor: ObsidianTheme.textOnPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final n = nameCtrl.text.trim();
                    if (n.isEmpty) return;
                    final id = service.generateId();
                    final preset = Preset(
                      id: id,
                      name: n,
                      trackNames: ctrl.slots.map((s) => s.name).toList(),
                    );
                    await service.save(preset);
                    ctrl.loadPreset(preset);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Preset "$n" created'),
                      backgroundColor: ObsidianTheme.primary,
                      duration: const Duration(seconds: 2),
                    ));
                  },
                  child: const Text('CREATE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoadSheet(BuildContext context) {
    final service = PresetService();
    showModalBottomSheet(
      context: context,
      backgroundColor: ObsidianTheme.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => FutureBuilder<List<Preset>>(
          future: service.loadAll(),
          builder: (_, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final presets = snap.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text('Load preset', style: ObsidianTheme.slotTitle),
                ),
                const SizedBox(height: 4),
                if (presets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No presets saved yet.',
                        style: ObsidianTheme.labelSmall
                            .copyWith(color: ObsidianTheme.textMuted),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: presets.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: ObsidianTheme.border, height: 1),
                      itemBuilder: (_, i) {
                        final p = presets[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(p.name, style: ObsidianTheme.slotTitle),
                          subtitle: Text(
                            p.trackNames
                                .where((n) => n.isNotEmpty)
                                .take(4)
                                .join(' · '),
                            style: ObsidianTheme.labelTiny
                                .copyWith(color: ObsidianTheme.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 18, color: ObsidianTheme.textMuted),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: ctx,
                                builder: (dCtx) => AlertDialog(
                                  backgroundColor: ObsidianTheme.cardBg,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  title: Text('Delete preset',
                                      style: ObsidianTheme.slotTitle),
                                  content: Text(
                                    'Delete "${p.name}"? This cannot be undone.',
                                    style: ObsidianTheme.labelSmall.copyWith(
                                        color: ObsidianTheme.textMuted),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dCtx, false),
                                      child: Text('Cancel',
                                          style: ObsidianTheme.labelSmall
                                              .copyWith(
                                                  color:
                                                      ObsidianTheme.textMuted)),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dCtx, true),
                                      child: Text('Delete',
                                          style: ObsidianTheme.labelSmall
                                              .copyWith(
                                                  color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await service.delete(p.id);
                                Navigator.pop(ctx);
                                _showLoadSheet(context);
                              }
                            },
                          ),
                          onTap: () {
                            ctrl.loadPreset(p);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Preset "${p.name}" loaded'),
                                backgroundColor: ObsidianTheme.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

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
          SizedBox(
            width: 32,
            height: 32,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 10),
          const Text('OBSIDIAN Neural', style: ObsidianTheme.appTitle),
          const SizedBox(width: 6),
          Text('Controller',
              style: ObsidianTheme.labelSmall
                  .copyWith(color: ObsidianTheme.textMuted)),
          const Spacer(),
          if (ctrl.currentPresetName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune, size: 14, color: ObsidianTheme.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    ctrl.currentPresetName!.toUpperCase(),
                    style: ObsidianTheme.labelSmall.copyWith(
                      color: ObsidianTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: () => _showSaveSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: ObsidianTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: ObsidianTheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined,
                      size: 14, color: ObsidianTheme.primary),
                  const SizedBox(width: 4),
                  Text('SAVE',
                      style: ObsidianTheme.labelSmall.copyWith(
                        color: ObsidianTheme.primary,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showLoadSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ObsidianTheme.cardBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ObsidianTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_open_outlined,
                      size: 14, color: ObsidianTheme.textMuted),
                  const SizedBox(width: 4),
                  Text('LOAD',
                      style: ObsidianTheme.labelSmall.copyWith(
                        color: ObsidianTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              print('🔄 Sync tapped');
              ctrl.syncState();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: ObsidianTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: ObsidianTheme.primary.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync, size: 14, color: ObsidianTheme.primary),
                  const SizedBox(width: 4),
                  Text('SYNC',
                      style: ObsidianTheme.labelSmall.copyWith(
                        color: ObsidianTheme.primary,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
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

class _TracksView extends StatefulWidget {
  final AppController ctrl;
  const _TracksView({required this.ctrl});

  @override
  State<_TracksView> createState() => _TracksViewState();
}

class _TracksViewState extends State<_TracksView> {
  int _selectedIndex = 0;
  final List<String> labels = [
    "T1",
    "T2",
    "T3",
    "T4",
    "Cross",
    "T5",
    "T6",
    "T7",
    "T8"
  ];
  final ScrollController _scrollController = ScrollController();
  static const double itemWidth = 280.0;

  void _scrollToIndex(int index) {
    const double itemWidthWithMargin = 290.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * itemWidthWithMargin) - (screenWidth / 2) + (280 / 2);

    _scrollController.animateTo(
      targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: 9,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(
                  width: itemWidth,
                  child: Center(
                    child: Opacity(
                      opacity: _selectedIndex == index ? 1.0 : 0.7,
                      child: _buildContent(index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(9, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = index);
                  _scrollToIndex(index);
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedIndex == index
                        ? ObsidianTheme.generateColor
                        : ObsidianTheme.cardBg,
                    border: Border.all(color: ObsidianTheme.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _selectedIndex == index
                            ? ObsidianTheme.textOnPrimary
                            : ObsidianTheme.textMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(int index) {
    const crossfaderIndex = 4;

    if (index == crossfaderIndex) {
      return CrossfaderPanel(
        pairValues: widget.ctrl.pairCrossfaders,
        curveMode: widget.ctrl.crossfaderCurveMode,
        onPairChanged: (idx, v) => widget.ctrl.setPairCrossfader(idx, v),
        onCurveChanged: (m) => widget.ctrl.setCrossfaderCurveMode(m),
      );
    }

    final slotIndex = index < crossfaderIndex ? index : index - 1;
    return SlotCard(
      slot: widget.ctrl.slots[slotIndex],
      isSelected: _selectedIndex == index,
      ctrl: widget.ctrl,
    );
  }
}
