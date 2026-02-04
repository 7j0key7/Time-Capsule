import 'package:flutter/material.dart';
import '../plugins/api.dart';
import 'create_screen.dart';
import 'edit_screen.dart';
import '../widgets/daily_capsule_button.dart';
import '../plugins/auth_service.dart';
import 'login_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> capsules = [];
  bool isLoading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    loadCapsules();
  }

  Future<void> loadCapsules() async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final data = await ApiService.getCapsules();

      data.sort((a, b) {
        final da = DateTime.tryParse('${a['createdAt'] ?? ''}') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final db = DateTime.tryParse('${b['createdAt'] ?? ''}') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

      setState(() {
        capsules = data;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        errorText = 'Не удалось загрузить капсулы';
        isLoading = false;
      });
    }
  }

  String fmt(dynamic raw) {
    final d = DateTime.tryParse('${raw ?? ''}');
    if (d == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year}';
  }

  bool opened(Map<String, dynamic> c) {
    final d = DateTime.tryParse('${c['openAt'] ?? ''}');
    return d != null && !DateTime.now().isBefore(d);
  }

  Future<void> goCreate() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateScreen()),
    );
    if (created == true) loadCapsules();
  }

  Future<void> goEdit(Map<String, dynamic> c) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditScreen(capsule: c)),
    );
    if (changed == true) loadCapsules();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
appBar: AppBar(
  backgroundColor: const Color(0xFF2B2F7A),
  centerTitle: true,
  title: const Text(
    'TimeCapsule',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevation: 0,
  actions: [
    IconButton(
      onPressed: () async {
        await AuthService.logout();
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      icon: const Icon(Icons.logout, color: Colors.white),
    ),
  ],
),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _content(),
          ),
          const DailyCapsuleButton(),
        ],
      ),
    );
  }

  Widget _content() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    if (errorText != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorText!, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: loadCapsules, child: const Text('Повторить')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: capsules.isEmpty
              ? const Center(
                  child: Text(
                    'Капсул пока нет.\nНажми кнопку ниже, чтобы создать.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              : ListView.builder(
                  itemCount: capsules.length,
                  itemBuilder: (_, i) {
                    final c = capsules[i] as Map<String, dynamic>;
                    final isOpen = opened(c);

                    final title = ('${c['title'] ?? ''}').trim();
                    final imageUrl = ('${c['imageUrl'] ?? ''}').trim();

                    final openAt = fmt(c['openAt']);
                    final createdAt = fmt(c['createdAt']);

                    final dateLine = openAt.isNotEmpty
                        ? 'Откроется: $openAt'
                        : (createdAt.isNotEmpty ? 'Создано: $createdAt' : '');

                    final subtitle =
                        isOpen ? ('${c['text'] ?? ''}') : 'Скрыто до открытия';

                    return CapsuleCard(
                      icon: isOpen ? Icons.lock_open : Icons.lock,
                      title: title.isEmpty ? '(без названия)' : title,
                      date: dateLine,
                      subtitle: subtitle,
                      imageUrl: imageUrl,
                      onTap: () => goEdit(c),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: goCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F5BD5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Создать новую капсулу',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CapsuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String subtitle;
  final String imageUrl;
  final VoidCallback onTap;

  const CapsuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.date,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2B2F7A), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EBFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2B2F7A)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(date, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                  if (imageUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            alignment: Alignment.center,
                            color: Colors.black12,
                            child: const Text('Фото недоступно'),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
