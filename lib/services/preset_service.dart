import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Preset {
  final String id;
  final String name;
  final List<String> trackNames;

  const Preset({
    required this.id,
    required this.name,
    required this.trackNames,
  });

  factory Preset.fromJson(Map<String, dynamic> json) => Preset(
        id: json['id'] as String,
        name: json['name'] as String,
        trackNames: List<String>.from(json['trackNames'] as List),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'trackNames': trackNames,
      };
}

class PresetService {
  static const _key = 'obsidian_presets';

  Future<List<Preset>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Preset.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> save(Preset preset) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    final idx = all.indexWhere((p) => p.id == preset.id);
    if (idx >= 0) {
      all[idx] = preset;
    } else {
      all.add(preset);
    }
    await prefs.setString(
        _key, jsonEncode(all.map((p) => p.toJson()).toList()));
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await prefs.setString(
        _key, jsonEncode(all.map((p) => p.toJson()).toList()));
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
