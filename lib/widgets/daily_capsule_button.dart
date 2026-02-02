import 'package:flutter/material.dart';
import '../plugins/daily_capsule_service.dart';

class DailyCapsuleButton extends StatefulWidget {
  const DailyCapsuleButton({super.key});

  @override
  State<DailyCapsuleButton> createState() => _DailyCapsuleButtonState();
}

class _DailyCapsuleButtonState extends State<DailyCapsuleButton> {
  Offset pos = const Offset(16, 0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safe = MediaQuery.of(context).padding;

    final double bottom = safe.bottom + 16;
    final double y =
        (pos.dy == 0) ? (size.height - bottom - 72) : pos.dy;

    final double x = pos.dx.clamp(8.0, size.width - 72);
    final double yy =
        y.clamp(safe.top + 8.0, size.height - 72 - bottom);

    return Positioned(
      left: x,
      top: yy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onPanUpdate: (d) {
          setState(() {
            pos = Offset(x + d.delta.dx, yy + d.delta.dy);
          });
        },

        onTap: () => _openCapsule(context),

        child: Container(
          width: 64,
          height: 64,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: const LinearGradient(
              colors: [
                Color(0xFF4F5BD5),
                Color(0xFF2B2F7A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            border: Border.all(
              color: Colors.white,
              width: 2,
            ),

            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),

          child: const Center(
            child: Icon(
              Icons.hourglass_top,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCapsule(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),

          child: FutureBuilder<Map<String, String>>(
            future: DailyCapsuleService.getTodayCapsule(),

            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snap.hasError || snap.data == null) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: Text('Ошибка загрузки')),
                );
              }

              final quote = snap.data!['quote'] ?? '';
              final author = snap.data!['author'] ?? '';

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Капсула дня',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EBFF),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Text(
                      '“$quote”',
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),

                  if (author.isNotEmpty) ...[
                    const SizedBox(height: 10),

                    Text(
                      '— $author',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F5BD5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),

                      child: const Text(
                        'Закрыть',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
