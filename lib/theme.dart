import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet gelap bernuansa keycap: latar arang, aksen amber.
class Warna {
  static const Color latar = Color(0xFF14161A);
  static const Color permukaan = Color(0xFF1C1F25);
  static const Color permukaanTinggi = Color(0xFF262A32);
  static const Color garis = Color(0xFF343A44);
  static const Color amber = Color(0xFFF2A33C);
  static const Color teks = Color(0xFFECEFF4);
  static const Color teksRedup = Color(0xFF959DAC);
}

class Lengkung {
  static const double kecil = 8;
  static const double sedang = 14;
  static const double besar = 20;
}

ThemeData temaKeebdex() {
  final mono = GoogleFonts.jetBrainsMono().fontFamily;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Warna.latar,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: const ColorScheme.dark(
      primary: Warna.amber,
      surface: Warna.permukaan,
      onPrimary: Color(0xFF17191D),
    ),
    textTheme: TextTheme(
      bodyMedium: const TextStyle(color: Warna.teks, fontSize: 13),
      labelSmall: TextStyle(fontFamily: mono, color: Warna.teksRedup),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Warna.amber,
        foregroundColor: const Color(0xFF17191D),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Lengkung.sedang),
        ),
      ),
    ),
  );
}

/// Dipakai untuk nilai teknis (prosesor, pin, VID/PID) agar mudah dibaca.
TextStyle gayaMono({double ukuran = 13, Color warna = Warna.teks}) =>
    GoogleFonts.jetBrainsMono(fontSize: ukuran, color: warna);
