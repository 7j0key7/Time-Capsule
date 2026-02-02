// edit_screen.dart
import 'package:flutter/material.dart';
import '../plugins/api.dart';

class EditScreen extends StatefulWidget {
  final Map<String, dynamic> capsule;

  const EditScreen({super.key, required this.capsule});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController titleCtrl;
  late final TextEditingController textCtrl;
  late final TextEditingController imgCtrl;

  DateTime? openDate;
  bool saving = false;
  bool deleting = false;

  String get id => '${widget.capsule['id'] ?? ''}';

  bool get canSave =>
      !saving &&
      !deleting &&
      openDate != null &&
      titleCtrl.text.trim().isNotEmpty &&
      textCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: '${widget.capsule['title'] ?? ''}');
    textCtrl = TextEditingController(text: '${widget.capsule['text'] ?? ''}');
    imgCtrl = TextEditingController(text: '${widget.capsule['imageUrl'] ?? ''}');
    openDate = DateTime.tryParse('${widget.capsule['openAt'] ?? ''}');

    titleCtrl.addListener(_tick);
    textCtrl.addListener(_tick);
    imgCtrl.addListener(_tick);
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

  bool get opened {
    final d = openDate;
    return d != null && !DateTime.now().isBefore(d);
  }

  Future<void> pickOpenDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: openDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => openDate = picked);
  }

  Future<void> openNow() async {
    if (saving || deleting) return;
    setState(() => saving = true);

    try {
      await ApiService.openCapsuleNow(id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при открытии капсулы')),
      );
      setState(() => saving = false);
    }
  }

  Future<void> save() async {
    if (!canSave) return;
    setState(() => saving = true);

    try {
      final openAtIso = DateTime(
        openDate!.year,
        openDate!.month,
        openDate!.day,
        12,
      ).toIso8601String();

      await ApiService.updateCapsule(
        id: id,
        title: titleCtrl.text.trim(),
        text: textCtrl.text.trim(),
        openAtIso: openAtIso,
        imageUrl: imgCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при сохранении')),
      );
      setState(() => saving = false);
    }
  }

  Future<void> deleteCapsule() async {
    if (deleting) return;
    setState(() => deleting = true);

    try {
      await ApiService.deleteCapsule(id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении')),
      );
      setState(() => deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = imgCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2F7A),
        title: const Text('Редактировать', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: deleting ? null : deleteCapsule,
            icon: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 10),
                    Text(
                      openDate == null
                          ? 'Выбрать дату открытия'
                          : 'Откроется: ${_fmt(openDate!)}',
                      style: const TextStyle(fontSize: 14),
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
              child: Stack(
                children: [
                  TextField(
                    controller: textCtrl,
                    maxLines: null,
                    expands: true,
                    enabled: opened,
                    decoration: const InputDecoration(
                      labelText: 'Текст капсулы',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (!opened)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.white.withOpacity(0.92),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Текст скрыт до открытия капсулы',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 240,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: saving ? null : openNow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B2F7A),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Открыть предварительно',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
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
                        'Сохранить изменения',
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
