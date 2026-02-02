import 'package:shared_preferences/shared_preferences.dart';
import 'daily_capsule_api.dart';

class DailyCapsuleService {
  static const _kDate = 'daily_capsule_date';
  static const _kQuote = 'daily_capsule_quote';
  static const _kAuthor = 'daily_capsule_author';

  static String _todayKey() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)}';
  }

  static Future<Map<String, String>> getTodayCapsule() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final savedDate = prefs.getString(_kDate);
    final savedQuote = prefs.getString(_kQuote);
    final savedAuthor = prefs.getString(_kAuthor);

    if (savedDate == today && savedQuote != null && savedQuote.isNotEmpty) {
      return {
        'quote': savedQuote,
        'author': savedAuthor ?? '',
      };
    }

    final data = await DailyCapsuleApi.getRandomQuote();
    final quote = (data['quote'] ?? '').toString();
    final author = (data['author'] ?? '').toString();

    await prefs.setString(_kDate, today);
    await prefs.setString(_kQuote, quote);
    await prefs.setString(_kAuthor, author);

    return {
      'quote': quote,
      'author': author,
    };
  }
}
