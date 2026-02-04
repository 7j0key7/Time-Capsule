import 'package:flutter/material.dart';
import '../plugins/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final loginCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  bool get canSubmit =>
      !loading &&
      loginCtrl.text.trim().isNotEmpty &&
      passCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    loginCtrl.addListener(_tick);
    passCtrl.addListener(_tick);
  }

  void _tick() => setState(() {});

  @override
  void dispose() {
    loginCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!canSubmit) return;
    setState(() => loading = true);

    final ok = await AuthService.register(
      login: loginCtrl.text,
      password: passCtrl.text,
    );

    if (!mounted) return;

    if (!ok) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Такой логин уже существует или данные пустые')),
      );
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2F7A),
        title: const Text('Регистрация', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: loginCtrl,
              decoration: const InputDecoration(
                labelText: 'Логин',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Пароль',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: canSubmit ? submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F5BD5),
                  disabledBackgroundColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Зарегистрироваться',
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
