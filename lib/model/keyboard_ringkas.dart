/// Satu entri pada daftar keyboard.
///
/// Endpoint daftar QMK hanya mengirim larik string berisi jalur folder,
/// misalnya `keebio/iris/rev8`. Kelas ini memecah string itu menjadi
/// bagian yang bisa ditampilkan: merek dan nama model.
class KeyboardRingkas {
  const KeyboardRingkas({
    required this.folder,
    required this.merek,
    required this.model,
  });

  final String folder;
  final String merek;
  final String model;

  factory KeyboardRingkas.dariFolder(String folder) {
    final bagian = folder.split('/');
    final merek = bagian.first;
    final sisa = bagian.length > 1 ? bagian.sublist(1) : <String>[];

    return KeyboardRingkas(
      folder: folder,
      merek: _rapikan(merek),
      model: sisa.isEmpty ? _rapikan(merek) : sisa.map(_rapikan).join(' '),
    );
  }

  /// `wilba_tech` -> `Wilba Tech`, `rev8` dibiarkan apa adanya.
  static String _rapikan(String mentah) {
    return mentah
        .split(RegExp(r'[_\-]'))
        .where((kata) => kata.isNotEmpty)
        .map((kata) => kata[0].toUpperCase() + kata.substring(1))
        .join(' ');
  }

  /// Dipakai saat menyaring daftar lewat kotak pencarian.
  bool cocok(String kata) {
    final k = kata.toLowerCase();
    return folder.toLowerCase().contains(k) ||
        merek.toLowerCase().contains(k) ||
        model.toLowerCase().contains(k);
  }
}
