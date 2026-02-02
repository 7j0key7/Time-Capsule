import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://697d918d97386252a2686b73.mockapi.io/capsules';

  static Future<List<dynamic>> getCapsules() async {
    final res = await http.get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as List<dynamic>;
    }
    throw Exception('Ошибка загрузки: ${res.statusCode}');
  }

  static Future<void> addCapsule({
    required String title,
    required String text,
    required String createdAtIso,
    required String openAtIso,
    String? imageUrl,
  }) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'text': text,
        'createdAt': createdAtIso,
        'openAt': openAtIso,
        'imageUrl': imageUrl ?? '',
      }),
    );

    if (res.statusCode != 201) {
      throw Exception('Ошибка добавления: ${res.statusCode}');
    }
  }

  static Future<void> updateCapsule({
    required String id,
    required String title,
    required String text,
    required String openAtIso,
    String? imageUrl,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'text': text,
        'openAt': openAtIso,
        if (imageUrl != null) 'imageUrl': imageUrl,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Ошибка обновления: ${res.statusCode}');
    }
  }

  static Future<void> openCapsuleNow(String id) async {
    final nowIso = DateTime.now().toIso8601String();

    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'openAt': nowIso}),
    );

    if (res.statusCode != 200) {
      throw Exception('Ошибка открытия: ${res.statusCode}');
    }
  }

  static Future<void> deleteCapsule(String id) async {
    final res = await http.delete(Uri.parse('$baseUrl/$id'));
    if (res.statusCode != 200) {
      throw Exception('Ошибка удаления: ${res.statusCode}');
    }
  }
}
