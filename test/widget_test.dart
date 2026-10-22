import 'package:flutter_test/flutter_test.dart';
import 'package:keebdex/model/keyboard_detail.dart';
import 'package:keebdex/model/keyboard_ringkas.dart';

void main() {
  group('KeyboardRingkas', () {
    test('memecah folder bertingkat menjadi merek dan model', () {
      final kb = KeyboardRingkas.dariFolder('keebio/iris/rev8');
      expect(kb.merek, 'Keebio');
      expect(kb.model, 'Iris Rev8');
    });

    test('folder tanpa garis miring memakai namanya sendiri', () {
      final kb = KeyboardRingkas.dariFolder('tada68');
      expect(kb.merek, 'Tada68');
      expect(kb.model, 'Tada68');
    });

    test('garis bawah pada nama merek diubah menjadi spasi', () {
      expect(KeyboardRingkas.dariFolder('wilba_tech/rama_works').merek,
          'Wilba Tech');
    });

    test('pencarian cocok pada merek maupun folder', () {
      final kb = KeyboardRingkas.dariFolder('kbdfans/kbd67/mkiirgb/v3');
      expect(kb.cocok('kbd67'), isTrue);
      expect(kb.cocok('KBDfans'), isTrue);
      expect(kb.cocok('planck'), isFalse);
    });
  });

  group('KeyboardDetail', () {
    final balasan = {
      'keyboards': {
        'contoh/papan': {
          'keyboard_name': 'Papan Contoh',
          'keyboard_folder': 'contoh/papan',
          'manufacturer': 'Contoh',
          'processor': 'atmega32u4',
          'usb': {'vid': '0x1234', 'pid': '0x5678'},
          'matrix_size': {'rows': 4, 'cols': 12},
          'features': {'nkro': true, 'audio': false, 'encoder': true},
          'layouts': {
            'LAYOUT_kecil': {
              'layout': [
                {'x': 0, 'y': 0},
                {'x': 1, 'y': 0, 'w': 2},
              ],
            },
            'LAYOUT_besar': {
              'layout': [
                {'x': 0, 'y': 0},
                {'x': 1, 'y': 0},
                {'x': 2, 'y': 0},
              ],
            },
          },
        },
      },
    };

    test('membaca spesifikasi dari balasan bersarang', () {
      final kb = KeyboardDetail.dariJson(balasan, 'contoh/papan');
      expect(kb.nama, 'Papan Contoh');
      expect(kb.pabrikan, 'Contoh');
      expect(kb.usbVid, '0x1234');
      expect(kb.barisMatriks, 4);
      expect(kb.kolomMatriks, 12);
    });

    test('hanya fitur bernilai true yang diambil', () {
      final kb = KeyboardDetail.dariJson(balasan, 'contoh/papan');
      expect(kb.fitur, containsAll(<String>['NKRO', 'Encoder']));
      expect(kb.fitur, isNot(contains('Audio')));
    });

    test('denah diurutkan dari tombol terbanyak', () {
      final kb = KeyboardDetail.dariJson(balasan, 'contoh/papan');
      expect(kb.denah.first.nama, 'LAYOUT_besar');
      expect(kb.denah.first.jumlahTombol, 3);
    });

    test('lebar tombol tanpa field w dianggap 1 unit', () {
      final kb = KeyboardDetail.dariJson(balasan, 'contoh/papan');
      final kecil = kb.denah.firstWhere((d) => d.nama == 'LAYOUT_kecil');
      expect(kecil.lebarUnit, 3);
      expect(kecil.tombol.first.w, 1);
    });

    test('field yang tidak dikirim API bernilai null, bukan melempar galat', () {
      final kb = KeyboardDetail.dariJson({
        'keyboards': {
          'x': {'keyboard_name': 'Minim'},
        },
      }, 'x');
      expect(kb.prosesor, isNull);
      expect(kb.usbVid, isNull);
      expect(kb.fitur, isEmpty);
      expect(kb.denah, isEmpty);
    });
  });
}
