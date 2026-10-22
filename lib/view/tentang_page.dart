import 'package:flutter/material.dart';

import '../theme.dart';

/// Halaman ketiga: identitas pembuat dan sumber data aplikasi.
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 20, 14),
              decoration: const BoxDecoration(color: Warna.permukaan),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Warna.teks,
                      size: 22,
                    ),
                    tooltip: 'Kembali',
                  ),
                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Warna.teks,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  _kotak(
                    judul: 'Keebdex',
                    isi: const [
                      'Aplikasi katalog keyboard custom yang seluruh datanya '
                          'diambil dari QMK Keyboards API. Pengguna dapat '
                          'menelusuri keyboard yang didukung firmware QMK, '
                          'lalu melihat spesifikasi dan denah tombolnya.',
                    ],
                  ),
                  const SizedBox(height: 14),
                  _kotak(
                    judul: 'Sumber data',
                    mono: true,
                    isi: const [
                      'GET keyboards.qmk.fm/v1/keyboard_list.json',
                      'GET keyboards.qmk.fm/v1/keyboards/<folder>/info.json',
                    ],
                  ),
                  const SizedBox(height: 14),
                  _kotak(
                    judul: 'Penyusun',
                    isi: const [
                      'Muktibaskara Kusbianto',
                      'NIM 240605110182',
                      'Kelas A — Mata Kuliah Pemrograman Mobile',
                      'Jurusan Teknik Informatika',
                      'UIN Maulana Malik Ibrahim Malang',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kotak({
    required String judul,
    required List<String> isi,
    bool mono = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Lengkung.sedang),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Warna.amber,
            ),
          ),
          const SizedBox(height: 10),
          for (final baris in isi) ...[
            Text(
              baris,
              style: mono
                  ? gayaMono(ukuran: 10, warna: Warna.teksRedup)
                  : const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Warna.teksRedup,
                    ),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
