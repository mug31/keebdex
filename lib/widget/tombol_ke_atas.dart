import 'package:flutter/material.dart';

import '../theme.dart';

/// Tombol kecil untuk kembali ke awal daftar setelah pengguna menggulir jauh.
///
/// Tombol baru muncul setelah gulirannya melewati [ambang], supaya tidak
/// menutupi isi ketika belum dibutuhkan, dan kembali tersembunyi begitu
/// pengguna sudah berada di dekat awal daftar.
class TombolKeAtas extends StatefulWidget {
  const TombolKeAtas({super.key, required this.pengendali, this.ambang = 400});

  final ScrollController pengendali;
  final double ambang;

  @override
  State<TombolKeAtas> createState() => _TombolKeAtasState();
}

class _TombolKeAtasState extends State<TombolKeAtas> {
  bool _tampil = false;

  @override
  void initState() {
    super.initState();
    widget.pengendali.addListener(_periksaPosisi);
  }

  @override
  void dispose() {
    widget.pengendali.removeListener(_periksaPosisi);
    super.dispose();
  }

  void _periksaPosisi() {
    if (!widget.pengendali.hasClients) return;

    final perlu = widget.pengendali.offset > widget.ambang;
    // setState hanya dipanggil ketika keadaannya benar-benar berubah,
    // sebab listener ini berjalan pada setiap piksel guliran.
    if (perlu != _tampil) setState(() => _tampil = perlu);
  }

  void _keAtas() {
    widget.pengendali.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_tampil,
      child: AnimatedSlide(
        offset: _tampil ? Offset.zero : const Offset(0, 0.6),
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _tampil ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Material(
            color: Warna.amber,
            shape: const CircleBorder(),
            elevation: 4,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _keAtas,
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Icons.arrow_upward,
                  size: 20,
                  color: Color(0xFF17191D),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
