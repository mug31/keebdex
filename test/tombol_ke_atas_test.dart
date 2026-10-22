import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keebdex/widget/tombol_ke_atas.dart';

/// Mencari widget tertentu khusus di dalam TombolKeAtas, sebab MaterialApp
/// juga memakai IgnorePointer dan AnimatedOpacity untuk keperluannya sendiri.
Finder _didalam(Type tipe) =>
    find.descendant(of: find.byType(TombolKeAtas), matching: find.byType(tipe));

/// Membangun daftar panjang berisi tombol kembali ke atas, persis seperti
/// susunan yang dipakai halaman daftar dan halaman detail.
Widget _layar(ScrollController gulir) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            controller: gulir,
            itemCount: 60,
            itemBuilder: (_, i) =>
                SizedBox(height: 80, child: Text('baris $i')),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: TombolKeAtas(pengendali: gulir),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('tombol tersembunyi sebelum daftar digulir', (tester) async {
    final gulir = ScrollController();
    addTearDown(gulir.dispose);

    await tester.pumpWidget(_layar(gulir));

    final opasitas = tester.widget<AnimatedOpacity>(_didalam(AnimatedOpacity));
    expect(opasitas.opacity, 0);

    final abai = tester.widget<IgnorePointer>(_didalam(IgnorePointer));
    expect(abai.ignoring, isTrue);
  });

  testWidgets('tombol muncul setelah guliran melewati ambang', (tester) async {
    final gulir = ScrollController();
    addTearDown(gulir.dispose);

    await tester.pumpWidget(_layar(gulir));
    gulir.jumpTo(500);
    await tester.pump();

    final opasitas = tester.widget<AnimatedOpacity>(_didalam(AnimatedOpacity));
    expect(opasitas.opacity, 1);
  });

  testWidgets('tombol tetap tersembunyi tepat pada ambang', (tester) async {
    final gulir = ScrollController();
    addTearDown(gulir.dispose);

    await tester.pumpWidget(_layar(gulir));
    gulir.jumpTo(400);
    await tester.pump();

    final opasitas = tester.widget<AnimatedOpacity>(_didalam(AnimatedOpacity));
    expect(opasitas.opacity, 0);
  });

  testWidgets('menekan tombol mengembalikan daftar ke awal', (tester) async {
    final gulir = ScrollController();
    addTearDown(gulir.dispose);

    await tester.pumpWidget(_layar(gulir));
    gulir.jumpTo(1200);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    expect(gulir.offset, 0);
  });

  testWidgets('tombol menghilang lagi setelah kembali ke awal', (tester) async {
    final gulir = ScrollController();
    addTearDown(gulir.dispose);

    await tester.pumpWidget(_layar(gulir));
    gulir.jumpTo(1200);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    final opasitas = tester.widget<AnimatedOpacity>(_didalam(AnimatedOpacity));
    expect(opasitas.opacity, 0);
  });
}
