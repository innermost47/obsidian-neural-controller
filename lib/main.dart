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

class ObsidianControllerApp extends StatefulWidget {
  const ObsidianControllerApp({super.key});
  @override
  State<ObsidianControllerApp> createState() => _ObsidianControllerAppState();
}

class _ObsidianControllerAppState extends State<ObsidianControllerApp> {
  late final MidiService midiService;
  late final AppController appController;

  @override
  void initState() {
    super.initState();
    midiService = MidiService();
    appController = AppController(midi: midiService);
  }

  @override
  void dispose() {
    appController.dispose();
    midiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MidiService>.value(value: midiService),
        ChangeNotifierProvider<AppController>.value(value: appController),
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
