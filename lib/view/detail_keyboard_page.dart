import 'package:flutter/material.dart';

import '../model/keyboard_detail.dart';
import '../service/qmk_api.dart';
import '../theme.dart';
import '../widget/denah_keyboard.dart';
import '../widget/status.dart';

/// Halaman kedua: spesifikasi satu keyboard beserta denah tombolnya.
class DetailKeyboardPage extends StatefulWidget {
  const DetailKeyboardPage({super.key, required this.folder});

  final String folder;

  @override
  State<DetailKeyboardPage> createState() => _DetailKeyboardPageState();
}

class _DetailKeyboardPageState extends State<DetailKeyboardPage> {
  late Future<KeyboardDetail> _detail;
  int _indeksDenah = 0;

  @override
  void initState() {
    super.initState();
    _detail = QmkApi.instance.ambilDetail(widget.folder);
  }

  void _muatUlang() {
    setState(() => _detail = QmkApi.instance.ambilDetail(widget.folder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea dipakai agar tombol kembali tidak tertutup bilah sistem
      // pada Android 15 yang memaksa tampilan edge-to-edge.
      body: SafeArea(
        child: FutureBuilder<KeyboardDetail>(
          future: _detail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Memuat(pesan: 'Mengambil spesifikasi…');
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                children: [
                  _bilahAtas(null),
                  Expanded(
                    child: Galat(
                      pesan: '${snapshot.error}',
                      onCoba: _muatUlang,
                    ),
                  ),
                ],
              );
            }

            final kb = snapshot.data!;
            final adaDenah = kb.denah.isNotEmpty;
            final indeks = adaDenah
                ? _indeksDenah.clamp(0, kb.denah.length - 1)
                : 0;

            return Column(
              children: [
                _bilahAtas(kb),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      if (adaDenah) ...[
                        _panelDenah(kb, indeks),
                        const SizedBox(height: 20),
                      ],
                      _judulBagian('Spesifikasi'),
                      const SizedBox(height: 10),
                      _tabelSpesifikasi(kb),
                      if (kb.fitur.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _judulBagian('Fitur firmware'),
                        const SizedBox(height: 10),
                        _daftarFitur(kb.fitur),
                      ],
                      if (kb.layoutKomunitas.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _judulBagian('Layout komunitas'),
                        const SizedBox(height: 10),
                        _daftarFitur(kb.layoutKomunitas),
                      ],
                      const SizedBox(height: 22),
                      _catatanSumber(kb),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Dipakai pada bilah atas ketika detail belum atau gagal dimuat,
  /// diambil dari segmen terakhir folder, misalnya `keychron/q1v2/ansi`
  /// menjadi `Ansi`.
  String get _namaCadangan {
    final potongan = widget.folder.split('/').last;
    if (potongan.isEmpty) return widget.folder;
    return potongan[0].toUpperCase() + potongan.substring(1);
  }

  Widget _bilahAtas(KeyboardDetail? kb) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 14),
      decoration: const BoxDecoration(color: Warna.permukaan),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Warna.teks, size: 22),
            tooltip: 'Kembali',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kb?.nama ?? _namaCadangan,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Warna.teks,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kb?.pabrikan ?? widget.folder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: gayaMono(ukuran: 10, warna: Warna.amber),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Denah tombol beserta pemilih varian susunan.
  Widget _panelDenah(KeyboardDetail kb, int indeks) {
    final denah = kb.denah[indeks];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Lengkung.sedang),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${denah.jumlahTombol} tombol',
                style: gayaMono(ukuran: 12, warna: Warna.amber),
              ),
              const Spacer(),
              Text(
                denah.nama,
                style: gayaMono(ukuran: 9, warna: Warna.teksRedup),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DenahKeyboard(denah: denah),
          if (kb.denah.length > 1) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < kb.denah.length; i++) ...[
                    _tombolVarian(
                      label: '${kb.denah[i].jumlahTombol}',
                      aktif: i == indeks,
                      onTap: () => setState(() => _indeksDenah = i),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Keyboard ini punya ${kb.denah.length} varian susunan tombol.',
              style: const TextStyle(fontSize: 10, color: Warna.teksRedup),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tombolVarian({
    required String label,
    required bool aktif,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Lengkung.kecil),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: aktif ? Warna.amber : Warna.permukaanTinggi,
          borderRadius: BorderRadius.circular(Lengkung.kecil),
          border: Border.all(color: aktif ? Warna.amber : Warna.garis),
        ),
        child: Text(
          label,
          style: gayaMono(
            ukuran: 11,
            warna: aktif ? const Color(0xFF17191D) : Warna.teksRedup,
          ),
        ),
      ),
    );
  }

  Widget _judulBagian(String teks) => Text(
    teks,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Warna.teks,
    ),
  );

  /// Hanya field yang benar-benar dikirim API yang ditampilkan, sehingga
  /// keyboard dengan data sebagian tidak memunculkan baris kosong.
  Widget _tabelSpesifikasi(KeyboardDetail kb) {
    final matriks = (kb.barisMatriks != null && kb.kolomMatriks != null)
        ? '${kb.barisMatriks} x ${kb.kolomMatriks}'
        : null;
    final usb = (kb.usbVid != null && kb.usbPid != null)
        ? '${kb.usbVid} / ${kb.usbPid}'
        : null;

    final baris = <String, String?>{
      'Folder QMK': kb.folder,
      'Pabrikan': kb.pabrikan,
      'Prosesor': kb.prosesor,
      'Jenis prosesor': kb.jenisProsesor,
      'Platform': kb.platform,
      'Bootloader': kb.bootloader,
      'Matriks (baris x kolom)': matriks,
      'Arah dioda': kb.arahDioda,
      'Jumlah LED': kb.jumlahLed?.toString(),
      'USB VID / PID': usb,
      'Versi perangkat': kb.versiPerangkat,
      'Pengelola': kb.pengelola,
      'Situs resmi': kb.situs,
    };

    final terisi = baris.entries.where((e) => e.value != null).toList();

    return Container(
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Lengkung.sedang),
        border: Border.all(color: Warna.garis),
      ),
      child: Column(
        children: [
          for (var i = 0; i < terisi.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                border: i == terisi.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: Warna.garis)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 132,
                    child: Text(
                      terisi[i].key,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Warna.teksRedup,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(terisi[i].value!, style: gayaMono(ukuran: 11)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _daftarFitur(List<String> isi) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final f in isi)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: Warna.permukaanTinggi,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Warna.garis),
            ),
            child: Text(f, style: gayaMono(ukuran: 10, warna: Warna.teks)),
          ),
      ],
    );
  }

  Widget _catatanSumber(KeyboardDetail kb) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Warna.permukaan,
        borderRadius: BorderRadius.circular(Lengkung.kecil),
        border: Border.all(color: Warna.garis),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.api, size: 15, color: Warna.teksRedup),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Data diambil langsung dari '
              'keyboards.qmk.fm/v1/keyboards/${kb.folder}/info.json',
              style: gayaMono(ukuran: 9, warna: Warna.teksRedup),
            ),
          ),
        ],
      ),
    );
  }
}
