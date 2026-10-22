/// Posisi satu tombol pada denah keyboard.
///
/// Satuannya unit keycap (1u = satu tombol normal), jadi `w: 2.25`
/// berarti tombol selebar 2,25 tombol biasa seperti Enter ANSI.
class Tombol {
  const Tombol({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  final double x;
  final double y;
  final double w;
  final double h;

  factory Tombol.dariJson(Map<String, dynamic> json) => Tombol(
    x: _angka(json['x']) ?? 0,
    y: _angka(json['y']) ?? 0,
    w: _angka(json['w']) ?? 1,
    h: _angka(json['h']) ?? 1,
  );
}

/// Satu varian susunan tombol. Sebuah keyboard bisa punya beberapa,
/// misalnya Planck menyediakan lima varian bentuk spacebar.
class Denah {
  const Denah({required this.nama, required this.tombol});

  final String nama;
  final List<Tombol> tombol;

  int get jumlahTombol => tombol.length;

  /// Lebar dan tinggi denah dalam satuan unit, dipakai widget penggambar
  /// untuk menghitung skala agar denah pas di lebar layar.
  double get lebarUnit =>
      tombol.fold(0, (maks, t) => t.x + t.w > maks ? t.x + t.w : maks);

  double get tinggiUnit =>
      tombol.fold(0, (maks, t) => t.y + t.h > maks ? t.y + t.h : maks);
}

/// Spesifikasi lengkap satu keyboard dari endpoint detail QMK.
class KeyboardDetail {
  const KeyboardDetail({
    required this.folder,
    required this.nama,
    required this.denah,
    this.pabrikan,
    this.pengelola,
    this.situs,
    this.prosesor,
    this.bootloader,
    this.platform,
    this.jenisProsesor,
    this.usbVid,
    this.usbPid,
    this.versiPerangkat,
    this.barisMatriks,
    this.kolomMatriks,
    this.arahDioda,
    this.jumlahLed,
    this.fitur = const [],
    this.layoutKomunitas = const [],
  });

  final String folder;
  final String nama;
  final List<Denah> denah;
  final String? pabrikan;
  final String? pengelola;
  final String? situs;
  final String? prosesor;
  final String? bootloader;
  final String? platform;
  final String? jenisProsesor;
  final String? usbVid;
  final String? usbPid;
  final String? versiPerangkat;
  final int? barisMatriks;
  final int? kolomMatriks;
  final String? arahDioda;
  final int? jumlahLed;

  /// Nama fitur yang bernilai true saja, sudah dirapikan untuk ditampilkan.
  final List<String> fitur;
  final List<String> layoutKomunitas;

  /// Balasan API membungkus datanya: `{"keyboards": {"<folder>": {...}}}`,
  /// sehingga objek yang dipakai harus diambil dari dalam dua lapis itu.
  factory KeyboardDetail.dariJson(Map<String, dynamic> balasan, String folder) {
    final pembungkus = balasan['keyboards'];
    if (pembungkus is! Map || pembungkus.isEmpty) {
      throw Exception('Balasan API tidak memuat data keyboard');
    }
    final data =
        (pembungkus[folder] ?? pembungkus.values.first) as Map<String, dynamic>;

    return KeyboardDetail(
      folder: data['keyboard_folder'] as String? ?? folder,
      nama: data['keyboard_name'] as String? ?? folder,
      denah: _bacaDenah(data['layouts']),
      pabrikan: data['manufacturer'] as String?,
      pengelola: data['maintainer'] as String?,
      situs: data['url'] as String?,
      prosesor: data['processor'] as String?,
      bootloader: data['bootloader'] as String?,
      platform: data['platform'] as String?,
      jenisProsesor: data['processor_type'] as String?,
      usbVid: _jalurTeks(data, ['usb', 'vid']),
      usbPid: _jalurTeks(data, ['usb', 'pid']),
      versiPerangkat: _jalurTeks(data, ['usb', 'device_version']),
      barisMatriks: _jalurAngka(data, ['matrix_size', 'rows'])?.toInt(),
      kolomMatriks: _jalurAngka(data, ['matrix_size', 'cols'])?.toInt(),
      arahDioda: data['diode_direction'] as String?,
      jumlahLed:
          (_jalurAngka(data, ['rgb_matrix', 'led_count']) ??
                  _jalurAngka(data, ['rgblight', 'led_count']))
              ?.toInt(),
      fitur: _bacaFitur(data['features']),
      layoutKomunitas: _bacaTeksLarik(data['community_layouts']),
    );
  }

  static List<Denah> _bacaDenah(Object? mentah) {
    if (mentah is! Map) return const [];

    final hasil = <Denah>[];
    mentah.forEach((nama, isi) {
      final tombolMentah = (isi is Map) ? isi['layout'] : null;
      if (tombolMentah is! List) return;

      hasil.add(
        Denah(
          nama: nama.toString(),
          tombol: tombolMentah
              .whereType<Map<String, dynamic>>()
              .map(Tombol.dariJson)
              .toList(),
        ),
      );
    });

    // Denah dengan tombol terbanyak ditaruh pertama agar yang paling
    // mewakili bentuk keyboard yang muncul lebih dulu.
    hasil.sort((a, b) => b.jumlahTombol.compareTo(a.jumlahTombol));
    return hasil;
  }

  static List<String> _bacaFitur(Object? mentah) {
    if (mentah is! Map) return const [];
    return mentah.entries
        .where((e) => e.value == true)
        .map((e) => _labelFitur(e.key.toString()))
        .toList()
      ..sort();
  }

  static const Map<String, String> _namaFitur = {
    'nkro': 'NKRO',
    'rgblight': 'RGB Underglow',
    'rgb_matrix': 'RGB Matrix',
    'oled': 'OLED',
    'encoder': 'Encoder',
    'audio': 'Audio',
    'backlight': 'Backlight',
    'bootmagic': 'Bootmagic',
    'mousekey': 'Mousekey',
    'extrakey': 'Extrakey',
    'dip_switch': 'DIP Switch',
    'console': 'Console',
    'command': 'Command',
  };

  static String _labelFitur(String kunci) =>
      _namaFitur[kunci] ??
      kunci
          .split('_')
          .map((k) => k.isEmpty ? k : k[0].toUpperCase() + k.substring(1))
          .join(' ');

  static List<String> _bacaTeksLarik(Object? mentah) =>
      mentah is List ? mentah.map((e) => e.toString()).toList() : const [];
}

double? _angka(Object? nilai) {
  if (nilai is num) return nilai.toDouble();
  if (nilai is String) return double.tryParse(nilai);
  return null;
}

/// Penelusur aman untuk objek bersarang: mengembalikan null bila salah satu
/// lapisnya tidak ada, tanpa melempar galat seperti pemaksaan tipe langsung.
Object? _jalur(Map<String, dynamic> data, List<String> kunci) {
  Object? kini = data;
  for (final k in kunci) {
    if (kini is! Map) return null;
    kini = kini[k];
  }
  return kini;
}

String? _jalurTeks(Map<String, dynamic> data, List<String> kunci) =>
    _jalur(data, kunci)?.toString();

double? _jalurAngka(Map<String, dynamic> data, List<String> kunci) =>
    _angka(_jalur(data, kunci));
