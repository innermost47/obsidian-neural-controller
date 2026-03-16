import 'package:vibration/vibration.dart';

class Haptic {
  static Future<void> light() async {
    final has = await Vibration.hasVibrator();
    if (has) {
      Vibration.vibrate(duration: 100);
    }
  }

  static Future<void> medium() async {
    final has = await Vibration.hasVibrator();
    if (has) {
      Vibration.vibrate(duration: 200);
    }
  }
}
