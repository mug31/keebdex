import 'package:flutter/material.dart';

import '../theme.dart';

/// Tampilan selagi permintaan ke API berjalan.
class Memuat extends StatelessWidget {
  const Memuat({super.key, required this.pesan});

  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Warna.amber, strokeWidth: 2.5),
          const SizedBox(height: 14),
          Text(
            pesan,
            style: const TextStyle(fontSize: 12, color: Warna.teksRedup),
          ),
        ],
      ),
    );
  }
}

/// Tampilan ketika permintaan ke API gagal, misalnya saat tidak ada
/// koneksi internet. Tombolnya memicu permintaan ulang.
class Galat extends StatelessWidget {
  const Galat({super.key, required this.pesan, required this.onCoba});

  final String pesan;
  final VoidCallback onCoba;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Warna.teksRedup, size: 38),
            const SizedBox(height: 14),
            const Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Warna.teks,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Warna.teksRedup),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onCoba,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
