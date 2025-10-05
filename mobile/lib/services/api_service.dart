import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/detection_result.dart';

class ApiService {
  // TODO: set to your FastAPI base URL
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<DetectionResult> uploadImageForDetection(File imageFile) async {
    final uri = Uri.parse('$baseUrl/detect');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw HttpException('Failed to detect: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return DetectionResult.fromJson(data);
  }

  Future<List<DetectionResult>> fetchHistory() async {
    final uri = Uri.parse('$baseUrl/history');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw HttpException('Failed to fetch history');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => DetectionResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<File> saveTempFile(List<int> bytes, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    return file.writeAsBytes(bytes, flush: true);
  }
}
