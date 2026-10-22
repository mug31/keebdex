import 'package:flutter/material.dart';

import 'theme.dart';
import 'view/daftar_keyboard_page.dart';
import 'view/detail_keyboard_page.dart';
import 'view/tentang_page.dart';

void main() {
  runApp(const KeebdexApp());
}

class KeebdexApp extends StatelessWidget {
  const KeebdexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keebdex',
      debugShowCheckedModeBanner: false,
      theme: temaKeebdex(),
      initialRoute: '/',
      routes: {
        '/': (context) => const DaftarKeyboardPage(),
        '/tentang': (context) => const TentangPage(),
      },
      // Halaman detail butuh folder keyboard yang dipilih, jadi rutenya
      // dibuat lewat onGenerateRoute agar argumen bisa dibaca dan
      // diteruskan ke konstruktor halaman.
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final folder = settings.arguments as String?;
          if (folder == null) return null;
          return MaterialPageRoute(
            builder: (context) => DetailKeyboardPage(folder: folder),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
