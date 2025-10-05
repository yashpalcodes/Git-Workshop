import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

import '../models/detection.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  late final String _baseUrl;
  late final Duration _timeout;

  ApiService._internal() {
    _baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://10.0.2.2:8000';
    final int timeoutMs = int.tryParse((dotenv.env['API_TIMEOUT_MS'] ?? '15000').trim()) ?? 15000;
    _timeout = Duration(milliseconds: timeoutMs);

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        sendTimeout: _timeout,
      ),
    );
  }

  String get baseUrl => _baseUrl;

  Future<DetectionResult> uploadDetection(XFile imageFile) async {
    final String filename = imageFile.name.isNotEmpty ? imageFile.name : imageFile.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
        contentType: http_parser.MediaType('image', _inferMimeSubtype(filename)),
      ),
    });

    final Response<dynamic> response = await _dio.post(
      '/detect',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final Map<String, dynamic> data = _normalizeResponse(response.data);
    return DetectionResult.fromJson(data);
  }

  Future<List<DetectionResult>> fetchHistory() async {
    final Response<dynamic> response = await _dio.get('/history');
    final List<dynamic> raw = response.data is List ? response.data as List<dynamic> :
        (response.data is Map && (response.data as Map)['items'] is List ? (response.data as Map)['items'] as List<dynamic> : <dynamic>[]);
    return raw.map((e) => DetectionResult.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        return decoded;
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  String _inferMimeSubtype(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'heic';
    return 'jpeg';
  }
}
