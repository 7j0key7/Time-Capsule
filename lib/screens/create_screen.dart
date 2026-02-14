import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../plugins/api.dart';
import '../web_notifications.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final titleCtrl = TextEditingController();
  final textCtrl = TextEditingController();
  final imgCtrl = TextEditingController();

  DateTime? openDate;
  bool saving = false;

  bool get canSave =>
      !saving &&
      openDate != null &&
      titleCtrl.text.trim().isNotEmpty &&
      textCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    titleCtrl.addListener(_tick);
    textCtrl.addListener(_tick);
    imgCtrl.addListener(_tick);

    if (kIsWeb) {
      WebNotifications.requestPermission();
    }
  }

  void _tick() => setState(() {});

  @override
  void dispose() {
    titleCtrl.dispose();
    textCtrl.dispose();
    imgCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  Future<void> pickOpenDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (openDate ?? now).add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => openDate = picked);
  }

  void _notifySaved() {
    if (!kIsWeb) return;

    WebNotifications.requestPermission().then((ok) {
      if (!ok) return;

      WebNotifications.show(
        title: 'Time Capsule',
        body: 'Капсула сохранена ✅',
      );
    });
  }

  void _scheduleWebReminder(Duration delay, {required String openAtIso}) {
    if (!kIsWeb) return;

    Timer(delay, () {
      WebNotifications.show(
        title: 'Time Capsule',
        body: 'Пора открыть капсулу 👀 (дата: $openAtIso)',
      );
    });
  }

  Future<void> save() async {
    if (!canSave) return;
    setState(() => saving = true);

    try {
      final createdAtIso = DateTime.now().toIso8601String();
      final openAtIso = DateTime(
        openDate!.year,
        openDate!.month,
        openDate!.day,
        12,
      ).toIso8601String();

      await ApiService.addCapsule(
        title: titleCtrl.text.trim(),
        text: textCtrl.text.trim(),
        createdAtIso: createdAtIso,
        openAtIso: openAtIso,
        imageUrl: imgCtrl.text.trim(),
      );

      _notifySaved();

      // _scheduleWebReminder(const Duration(seconds: 10), openAtIso: openAtIso);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Ошибка сохранения: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = imgCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2F7A),
        title: const Text('Создать капсулу', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: pickOpenDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 10),
                    Text(
                      openDate == null
                          ? 'Выбрать дату открытия'
                          : 'Откроется: ${_fmt(openDate!)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: imgCtrl,
              decoration: const InputDecoration(
                labelText: 'Ссылка на фото (URL)',
                border: OutlineInputBorder(),
              ),
            ),
            if (url.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      alignment: Alignment.center,
                      color: Colors.black12,
                      child: const Text('Не удалось загрузить фото'),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: textCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'Текст капсулы',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSave ? save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F5BD5),
                  disabledBackgroundColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Сохранить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
