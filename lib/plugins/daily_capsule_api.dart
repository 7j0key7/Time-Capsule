import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyCapsuleApi {
  static Future<Map<String, dynamic>> getRandomQuote() async {
    final res = await http.get(Uri.parse('https://dummyjson.com/quotes/random'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load quote: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
