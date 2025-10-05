import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection_result.dart';

class HistoryService extends ChangeNotifier {
  static const String _key = 'detection_history';
  final List<DetectionResult> _history = [];

  List<DetectionResult> get history => List.unmodifiable(_history);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      final list = (jsonDecode(jsonStr) as List<dynamic>)
          .map((e) => DetectionResult.fromJson(e as Map<String, dynamic>))
          .toList();
      _history
        ..clear()
        ..addAll(list);
      notifyListeners();
    }
  }

  Future<void> add(DetectionResult result) async {
    _history.insert(0, result);
    notifyListeners();
    await _persist();
  }

  Future<void> clear() async {
    _history.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonStr);
  }
}
