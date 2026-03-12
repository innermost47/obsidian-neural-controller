import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../midi/midi_service.dart';
import '../model/app_controller.dart';
import '../ui/main_screen.dart';
import '../ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const ObsidianControllerApp());
}

class ObsidianControllerApp extends StatelessWidget {
  const ObsidianControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final midiService = MidiService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MidiService>.value(value: midiService),
        ChangeNotifierProvider<AppController>(
          create: (_) => AppController(midi: midiService),
        ),
      ],
      child: MaterialApp(
        title: 'OBSIDIAN Neural',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: ObsidianTheme.bgCream,
          colorScheme: ColorScheme.light(
            primary: ObsidianTheme.primary,
            surface: ObsidianTheme.bgCream,
          ),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        home: const ObsidianMainScreen(),
      ),
    );
  }
}
