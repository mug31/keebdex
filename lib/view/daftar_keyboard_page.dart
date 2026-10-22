import 'package:flutter/material.dart';

import '../model/keyboard_ringkas.dart';
import '../service/qmk_api.dart';
import '../theme.dart';
import '../widget/kartu_keyboard.dart';
import '../widget/status.dart';

/// Halaman utama: seluruh keyboard yang didukung QMK, bisa dicari
/// dan disaring per merek.
class DaftarKeyboardPage extends StatefulWidget {
  const DaftarKeyboardPage({super.key});

  @override
  State<DaftarKeyboardPage> createState() => _DaftarKeyboardPageState();
}

class _DaftarKeyboardPageState extends State<DaftarKeyboardPage> {
  late Future<List<KeyboardRingkas>> _daftar;
  final TextEditingController _pencarian = TextEditingController();
  String _merekAktif = _semua;

  static const String _semua = 'Semua';

  /// Merek yang paling banyak papannya di QMK, dipakai sebagai pintasan
  /// penyaring. Nilainya disamakan dengan segmen pertama folder.
  static const List<String> _merekPintas = [
    'keychron',
    'cannonkeys',
    'keebio',
    'kbdfans',
    'mechlovin',
    'wilba_tech',
    'mechwild',
    'xelus',
  ];

  @override
  void initState() {
    super.initState();
    _daftar = QmkApi.instance.ambilDaftar();
  }

  @override
  void dispose() {
    _pencarian.dispose();
    super.dispose();
  }

  void _muatUlang() {
    setState(() => _daftar = QmkApi.instance.ambilDaftar());
  }

  /// true ketika pencarian atau penyaring merek sedang aktif, sehingga
  /// jumlah keseluruhan perlu ditampilkan sebagai pembanding.
  bool get _sedangDisaring =>
      _merekAktif != _semua || _pencarian.text.trim().isNotEmpty;

  List<KeyboardRingkas> _saring(List<KeyboardRingkas> semua) {
    final kata = _pencarian.text.trim();

    return semua.where((kb) {
      final lolosMerek =
          _merekAktif == _semua || kb.folder.startsWith('$_merekAktif/');
      final lolosKata = kata.isEmpty || kb.cocok(kata);
      return lolosMerek && lolosKata;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _kepala(),
            Expanded(
              child: FutureBuilder<List<KeyboardRingkas>>(
                future: _daftar,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Memuat(pesan: 'Mengunduh daftar keyboard…');
                  }
                  if (snapshot.hasError) {
                    return Galat(
                      pesan: '${snapshot.error}',
                      onCoba: _muatUlang,
                    );
                  }

                  final hasil = _saring(snapshot.data ?? const []);
                  if (hasil.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada keyboard yang cocok.',
                        style: TextStyle(color: Warna.teksRedup),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                        child: Row(
                          children: [
                            Text(
                              '${hasil.length} keyboard',
                              style: gayaMono(
                                ukuran: 11,
                                warna: Warna.teksRedup,
                              ),
                            ),
                            const Spacer(),
                            // Jumlah keseluruhan hanya berguna sebagai
                            // pembanding ketika daftar sedang disaring;
                            // tanpa saringan angkanya sama persis.
                            if (_sedangDisaring)
                              Text(
                                'dari ${snapshot.data!.length} keyboard',
                                style: gayaMono(
                                  ukuran: 11,
                                  warna: Warna.teksRedup,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          itemCount: hasil.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => KartuKeyboard(
                            keyboard: hasil[i],
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/detail',
                              arguments: hasil[i].folder,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kepala() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Lengkung.besar),
          bottomRight: Radius.circular(Lengkung.besar),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.keyboard_alt_outlined,
                          color: Warna.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Keebdex',
                          style: gayaMono(ukuran: 20)
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Jelajah spesifikasi keyboard custom',
                      style: TextStyle(fontSize: 11, color: Warna.teksRedup),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/tentang'),
                icon: const Icon(Icons.info_outline, color: Warna.teksRedup),
                tooltip: 'Tentang aplikasi',
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pencarian,
            onChanged: (_) => setState(() {}),
            style: gayaMono(ukuran: 13),
            decoration: InputDecoration(
              hintText: 'Cari nama atau merek…',
              hintStyle: const TextStyle(fontSize: 12, color: Warna.teksRedup),
              prefixIcon: const Icon(
                Icons.search,
                size: 18,
                color: Warna.teksRedup,
              ),
              suffixIcon: _pencarian.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: Warna.teksRedup,
                      onPressed: () {
                        _pencarian.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: Warna.latar,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Lengkung.sedang),
                borderSide: const BorderSide(color: Warna.garis),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Lengkung.sedang),
                borderSide: const BorderSide(color: Warna.garis),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Lengkung.sedang),
                borderSide: const BorderSide(color: Warna.amber),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final merek in [_semua, ..._merekPintas]) ...[
                  ChipMerek(
                    label: merek == _semua
                        ? _semua
                        : KeyboardRingkas.dariFolder(merek).merek,
                    aktif: merek == _merekAktif,
                    onTap: () => setState(() => _merekAktif = merek),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
