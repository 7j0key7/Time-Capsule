import 'package:flutter/material.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая капсула'),
        backgroundColor: const Color(0xFF2B2F7A),
      ),
      body: const Center(
        child: Text(
          'Здесь будет форма для создания новой капсулы',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
