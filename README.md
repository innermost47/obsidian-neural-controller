# OBSIDIAN Neural — Mobile Controller

> A Flutter-based USB MIDI surface controller for the [OBSIDIAN Neural VST3 plugin](https://github.com/innermost47/ai-dj) — real-time AI music generation for live performance.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-blue)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](https://github.com/innermost47/ai-dj)
[![MIDI](https://img.shields.io/badge/MIDI-USB%20%7C%20CoreMIDI-orange)](https://github.com/innermost47/ai-dj)
[![License](https://img.shields.io/badge/License-AGPL%20v3-blue)](https://github.com/innermost47/ai-dj/blob/main/LICENSE)

<div align="center">
  <img src="assets/screen.jpg" alt="OBSIDIAN Neural mobile MIDI surface controller landscape UI for tablet and mobile, showing generative AI and mixing features" width="800"/>
  <p><i>Seamless live workflow: Instantly generate unique AI loops and craft your mix with high-precision touch controls.</i></p>
</div>

## What is this?

This app turns your Android or iOS device into a **dedicated hardware-style controller** for OBSIDIAN Neural. Control all 8 slots directly from your phone or tablet, hands-free from your DAW, during live performance.

**OBSIDIAN Neural** is a VST3 plugin for real-time AI loop generation — type a text prompt, get an audio loop instantly, triggerable via MIDI. [→ Learn more](https://github.com/innermost47/ai-dj)

---

## Features

- **8 slot cards** — one per OBSIDIAN track, scrollable horizontally
- **Per slot:** Volume fader · Pan knob · Pitch · Fine tune · Play · Stop · Generate · Mute · Solo · Beat Repeat
- **Pages A/B/C/D** — switch track variations instantly
- **8 Sequencer patterns** per slot (2-row grid, finger-friendly)
- **Master panel** — Master volume, pan, prev/next track navigation
- **Auto-connect** — plug your USB MIDI cable, the app connects automatically
- **Plug & play** — zero configuration, hardcoded MIDI mapping on Ch.1
- **Landscape only** — optimized for tablet and phone in landscape mode

---

## Requirements

|                 | Android              | iOS                              |
| --------------- | -------------------- | -------------------------------- |
| **Min version** | Android 6.0 (API 23) | iOS 11+                          |
| **Connection**  | USB Host (OTG cable) | USB-C or Lightning → USB adapter |
| **MIDI**        | `android.media.midi` | CoreMIDI                         |

---

## Getting Started

### 1. Connect your device

- **Android:** Use a USB OTG cable between your phone and the MIDI interface connected to your DAW machine
- **iOS:** Use a USB-C → USB-A Camera Connection Kit (or Lightning → USB3 adapter) + external power if needed

The app detects and connects to the first available USB MIDI device automatically.

### 2. Build & install

```bash
git clone https://github.com/innermost47/ai-dj.git   # or your fork
cd obsidian-controller

flutter pub get
flutter build apk --release          # Android
flutter install                      # Install directly via USB debug
```

For iOS (requires macOS + Xcode):

```bash
flutter build ipa
# Open ios/Runner.xcworkspace in Xcode to sign and install
```

### 3. Enable Developer Mode (Windows only)

Flutter requires symlink support on Windows:

```
Settings → Developer Mode → On
```

Or run: `start ms-settings:developers`

---

## MIDI Mapping (Ch.1, hardcoded)

| Control               | MIDI Message                                 |
| --------------------- | -------------------------------------------- |
| Play Slot 1–8         | Note On C4–G4 (notes 60–67)                  |
| Volume Slot 1–8       | CC 20–27                                     |
| Pan Slot 1–8          | CC 30–37                                     |
| Mute Slot 1–8         | CC 40–47 `(127=on, 0=off)`                   |
| Solo Slot 1–8         | CC 50–57 `(127=on, 0=off)`                   |
| Generate Slot 1–8     | CC 60–67 `(pulse 127→0)`                     |
| Stop Slot 1–8         | CC 70–77 `(pulse 127→0)`                     |
| Next / Prev Track     | CC 80–81                                     |
| Page A/B/C/D Slot 1–8 | CC 90–97 `(0=A, 32=B, 64=C, 96=D)`           |
| Pitch Slot 1–8        | CC 100–107 `(0=−12st, 64=center, 127=+12st)` |
| Fine Tune Slot 1–8    | CC 110–117 `(0=−50¢, 64=center, 127=+50¢)`   |
| Beat Repeat Slot 1–8  | CC 120–127 `(127=on, 0=off)`                 |
| Seq Pattern Slot 1–8  | CC 16–23 `(0–127 → seq 1–8)`                 |
| Master Volume         | CC 7                                         |
| Master Pan            | CC 10                                        |

These CCs must be mapped in OBSIDIAN Neural's MIDI Learn system. Right-click any parameter in the plugin → **MIDI Learn** → move the corresponding control in this app.

---

## Architecture

```
lib/
├── main.dart                    # Entry point — landscape lock, providers
├── midi/
│   ├── midi_mapping.dart        # All CC/Note constants (Ch.1, hardcoded)
│   └── midi_service.dart        # flutter_midi_command wrapper, auto-connect
├── model/
│   ├── models.dart              # SlotState, MasterState (immutable)
│   └── app_controller.dart      # ChangeNotifier — UI ↔ MIDI bridge
└── ui/
    ├── theme.dart               # OBSIDIAN color palette & typography
    ├── main_screen.dart         # TopBar + horizontal scroll + MasterPanel
    └── widgets/
        ├── controls.dart        # ObsidianKnob, ObsidianFader, ObsidianPill…
        ├── slot_card.dart       # Full slot card (volume, pan, pitch, pages, seq…)
        └── master_panel.dart    # Master vol/pan + nav + MIDI legend
```

**Dependencies:**

- [`flutter_midi_command ^0.5.1`](https://pub.dev/packages/flutter_midi_command) — USB MIDI for Android & iOS
- [`provider ^6.1.1`](https://pub.dev/packages/provider) — state management

---

## Roadmap

### V2 — Bidirectional MIDI feedback (plugin → app)

The plugin will send CC state updates from `timerCallback()` at 30Hz. The app will listen via `_midi.onMidiDataReceived` and reflect the plugin state in real time:

| CC       | State                          |
| -------- | ------------------------------ |
| CC 0–7   | isPlaying slot 1–8             |
| CC 8–15  | isGenerating slot 1–8          |
| CC 16–23 | Current volume slot 1–8        |
| CC 24–31 | isMuted slot 1–8               |
| CC 32–39 | isSolo slot 1–8                |
| CC 40–47 | Current page slot 1–8          |
| CC 48–55 | Active sequencer step slot 1–8 |
| CC 56    | Host BPM (value/2)             |
| CC 57    | Host isPlaying                 |

---

## Related

- 🔌 **[OBSIDIAN Neural VST3](https://github.com/innermost47/ai-dj)** — the plugin this app controls
- 🌐 **[obsidian-neural.com](https://obsidian-neural.com)** — API, documentation, pricing
- 🥁 **[BeatCrafter](https://github.com/innermost47/beatcrafter)** — AI MIDI drum pattern generator VST3

---

## License

GNU Affero General Public License v3.0 — see [LICENSE](https://github.com/innermost47/ai-dj/blob/main/LICENSE)

---

_Made with 🎵 in France by [InnerMost47](https://github.com/innermost47)_
