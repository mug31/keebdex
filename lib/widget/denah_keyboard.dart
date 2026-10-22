import 'package:flutter/material.dart';

import '../model/keyboard_detail.dart';
import '../theme.dart';

/// Menggambar bentuk fisik keyboard dari koordinat yang dikirim API.
///
/// Tidak ada satu pun gambar yang diunduh: tiap tombol adalah persegi
/// yang digambar ulang berdasarkan nilai x, y, w, dan h pada balasan JSON.
class DenahKeyboard extends StatelessWidget {
  const DenahKeyboard({super.key, required this.denah});

  final Denah denah;

  @override
  Widget build(BuildContext context) {
    final lebarUnit = denah.lebarUnit;
    final tinggiUnit = denah.tinggiUnit;
    if (lebarUnit <= 0 || tinggiUnit <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, batas) {
        // Skala dihitung dari lebar yang tersedia supaya denah selebar
        // apa pun (makropad 2 tombol sampai papan penuh 108 tombol)
        // tetap muat tanpa digulir mendatar.
        final skala = batas.maxWidth / lebarUnit;

        return SizedBox(
          width: batas.maxWidth,
          height: tinggiUnit * skala,
          child: Stack(
            children: [
              for (final tombol in denah.tombol)
                Positioned(
                  left: tombol.x * skala,
                  top: tombol.y * skala,
                  width: tombol.w * skala,
                  height: tombol.h * skala,
                  child: _Keycap(skala: skala),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Keycap extends StatelessWidget {
  const _Keycap({required this.skala});

  final double skala;

  @override
  Widget build(BuildContext context) {
    // Sela antar tombol dibuat proporsional terhadap skala agar denah
    // papan besar tidak terlihat rapat dan papan kecil tidak terlalu renggang.
    final sela = (skala * 0.055).clamp(0.8, 3.0);

    return Padding(
      padding: EdgeInsets.all(sela),
      child: Container(
        decoration: BoxDecoration(
          color: Warna.permukaanTinggi,
          borderRadius: BorderRadius.circular((skala * 0.12).clamp(2.0, 6.0)),
          border: Border.all(color: Warna.garis, width: 0.8),
        ),
        child: FractionallySizedBox(
          widthFactor: 0.82,
          heightFactor: 0.62,
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: sela * 0.8),
            decoration: BoxDecoration(
              color: Warna.permukaan,
              borderRadius: BorderRadius.circular(
                (skala * 0.08).clamp(1.5, 4.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
