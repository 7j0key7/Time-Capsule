import 'dart:html' as html;

class WebNotifications {
  static Future<bool> requestPermission() async {
    if (!html.Notification.supported) return false;

    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  static void show({
    required String title,
    String? body,
  }) {
    if (!html.Notification.supported) return;
    if (html.Notification.permission != 'granted') return;

    html.Notification(title, body: body ?? '');
  }
}
