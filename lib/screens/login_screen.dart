import 'package:flutter/material.dart';
import '../plugins/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    final ok = await AuthService.login(
      login: loginCtrl.text,
      password: passCtrl.text,
    );

    if (!mounted) return;

    if (!ok) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неверный логин или пароль')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> goRegister() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Регистрация успешна. Теперь войдите.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2F7A),
        centerTitle: true,
        title: const Text(
          'Вход',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
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
                        'Войти',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: loading ? null : goRegister,
              child: const Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}
