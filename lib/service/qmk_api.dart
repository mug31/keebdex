import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/keyboard_detail.dart';
import '../model/keyboard_ringkas.dart';

/// Lapisan pengambilan data dari QMK Keyboards API.
///
/// Dua endpoint yang dipakai:
///   GET `/v1/keyboard_list.json`            -> daftar seluruh folder keyboard
///   GET `/v1/keyboards/<folder>/info.json`  -> spesifikasi satu keyboard
class QmkApi {
  QmkApi._();

  static final QmkApi instance = QmkApi._();

  static const String _basis = 'https://keyboards.qmk.fm/v1';

  /// Daftar keyboard disimpan di memori setelah permintaan pertama karena
  /// isinya tetap untuk satu sesi, sehingga pindah halaman tidak memicu
  /// pengunduhan ulang.
  List<KeyboardRingkas>? _simpananDaftar;
  final Map<String, KeyboardDetail> _simpananDetail = {};

  Future<List<KeyboardRingkas>> ambilDaftar() async {
    if (_simpananDaftar != null) return _simpananDaftar!;

    final json = await _minta('$_basis/keyboard_list.json');
    final mentah = json['keyboards'];
    if (mentah is! List) {
      throw Exception('Format daftar keyboard tidak dikenali');
    }

    final daftar = mentah
        .map((e) => KeyboardRingkas.dariFolder(e.toString()))
        .toList();
    daftar.sort((a, b) => a.folder.compareTo(b.folder));

    _simpananDaftar = daftar;
    return daftar;
  }

  Future<KeyboardDetail> ambilDetail(String folder) async {
    final tersimpan = _simpananDetail[folder];
    if (tersimpan != null) return tersimpan;

    final json = await _minta('$_basis/keyboards/$folder/info.json');
    final detail = KeyboardDetail.dariJson(json, folder);

    _simpananDetail[folder] = detail;
    return detail;
  }

  /// Satu-satunya tempat permintaan HTTP dilakukan, agar penanganan galat
  /// jaringan dan penguraian JSON tidak tersebar di banyak berkas.
  Future<Map<String, dynamic>> _minta(String alamat) async {
    final tanggapan = await http
        .get(Uri.parse(alamat))
        .timeout(const Duration(seconds: 20));

    if (tanggapan.statusCode != 200) {
      throw Exception('Server menjawab ${tanggapan.statusCode}');
    }

    final isi = jsonDecode(utf8.decode(tanggapan.bodyBytes));
    if (isi is! Map<String, dynamic>) {
      throw Exception('Balasan server bukan objek JSON');
    }
    return isi;
  }
}
