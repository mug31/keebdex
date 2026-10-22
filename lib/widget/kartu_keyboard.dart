import 'package:flutter/material.dart';

import '../model/keyboard_ringkas.dart';
import '../theme.dart';

/// Satu baris pada daftar keyboard.
class KartuKeyboard extends StatelessWidget {
  const KartuKeyboard({super.key, required this.keyboard, required this.onTap});

  final KeyboardRingkas keyboard;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Lengkung.sedang),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Warna.permukaan,
          borderRadius: BorderRadius.circular(Lengkung.sedang),
          border: Border.all(color: Warna.garis),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Warna.permukaanTinggi,
                borderRadius: BorderRadius.circular(Lengkung.kecil),
                border: Border.all(color: Warna.garis),
              ),
              child: const Icon(
                Icons.keyboard_alt_outlined,
                size: 20,
                color: Warna.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    keyboard.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Warna.teks,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        keyboard.merek,
                        style: gayaMono(ukuran: 10, warna: Warna.amber),
                      ),
                      Text(
                        '  ·  ',
                        style: gayaMono(ukuran: 10, warna: Warna.garis),
                      ),
                      Expanded(
                        child: Text(
                          keyboard.folder,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: gayaMono(ukuran: 10, warna: Warna.teksRedup),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Warna.teksRedup, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Chip penyaring merek.
class ChipMerek extends StatelessWidget {
  const ChipMerek({
    super.key,
    required this.label,
    required this.aktif,
    required this.onTap,
  });

  final String label;
  final bool aktif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: aktif ? Warna.amber : Warna.permukaan,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: aktif ? Warna.amber : Warna.garis),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: aktif ? const Color(0xFF17191D) : Warna.teksRedup,
          ),
        ),
      ),
    );
  }
}
