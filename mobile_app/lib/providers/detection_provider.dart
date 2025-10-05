import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/detection.dart';
import '../services/api_service.dart';

class DetectionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isUploading = false;
  String? _lastError;
  DetectionResult? _lastResult;
  final List<DetectionResult> _history = <DetectionResult>[];

  bool get isUploading => _isUploading;
  String? get lastError => _lastError;
  DetectionResult? get lastResult => _lastResult;
  List<DetectionResult> get history => List.unmodifiable(_history);

  Future<void> initialize() async {
    await loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final items = await _api.fetchHistory();
      _history
        ..clear()
        ..addAll(items);
      await _saveHistoryToLocal();
      _lastError = null;
    } catch (_) {
      // Fallback to local cache
      await _loadHistoryFromLocal();
    }
    notifyListeners();
  }

  Future<void> uploadAndDetect(XFile imageFile) async {
    _isUploading = true;
    _lastError = null;
    notifyListeners();

    try {
      final result = await _api.uploadDetection(imageFile);
      _lastResult = result;
      _history.insert(0, result);
      await _saveHistoryToLocal();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> _saveHistoryToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('detection_history', DetectionResult.encodeList(_history));
    } catch (_) {
      // ignore local persistence errors
    }
  }

  Future<void> _loadHistoryFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('detection_history');
      if (data != null) {
        final items = DetectionResult.decodeList(data);
        _history
          ..clear()
          ..addAll(items);
      }
    } catch (_) {
      // ignore local persistence errors
    }
  }
}
