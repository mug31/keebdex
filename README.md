# Keebdex — Katalog Keyboard Custom QMK

Aplikasi mobile Flutter yang menampilkan katalog keyboard custom beserta
spesifikasinya. Seluruh data diambil langsung dari **QMK Keyboards API**
saat aplikasi dijalankan; tidak ada data yang ditanam di dalam kode.

Dikerjakan sebagai tugas Ujian Tengah Semester mata kuliah Pemrograman
Mobile.

| | |
|---|---|
| Nama | Muktibaskara Kusbianto |
| NIM | 240605110182 |
| Kelas | A |
| Jurusan | Teknik Informatika |
| Institusi | UIN Maulana Malik Ibrahim Malang |

## Tema dan tujuan

Keyboard mekanis custom punya ekosistem yang luas: ribuan papan dari ratusan
pembuat, masing-masing dengan mikrokontroler, jumlah tombol, dan dukungan
fitur firmware yang berbeda. Informasi itu tersebar di berkas konfigurasi
repositori QMK dan tidak nyaman dibaca lewat ponsel.

Keebdex mengumpulkannya menjadi satu katalog yang bisa ditelusuri: pengguna
mencari papan yang diminati, lalu melihat spesifikasi teknisnya dan bentuk
susunan tombolnya tanpa perlu membuka repositori firmware.

## Sumber data

[QMK Keyboards API](https://keyboards.qmk.fm) — publik, tanpa kunci API.

| Endpoint | Kegunaan |
|---|---|
| `GET /v1/keyboard_list.json` | Daftar seluruh folder keyboard yang didukung QMK (±3.760 papan) |
| `GET /v1/keyboards/<folder>/info.json` | Spesifikasi satu keyboard: pabrikan, prosesor, bootloader, matriks, fitur, dan koordinat tiap tombol |

## Daftar halaman

| Halaman | Rute | Fungsi |
|---|---|---|
| Daftar Keyboard | `/` | Menampilkan seluruh keyboard dari API. Dilengkapi kotak pencarian (nama, merek, atau folder) dan chip penyaring merek. |
| Detail Keyboard | `/detail` | Spesifikasi lengkap satu keyboard, denah tombol yang digambar dari koordinat API, pemilih varian susunan, serta daftar fitur firmware. |
| Tentang | `/tentang` | Keterangan aplikasi, endpoint yang dipakai, dan identitas penyusun. |

Perpindahan halaman memakai named route melalui `Navigator.pushNamed`.
Rute `/detail` dibuat lewat `onGenerateRoute` karena perlu menerima
argumen berupa folder keyboard yang dipilih.

## Fitur

- Pengambilan data dari dua endpoint API dengan `package:http`.
- Pencarian langsung pada daftar hasil unduhan.
- Penyaringan berdasarkan merek.
- **Penggambaran denah keyboard dari data API.** Field `layouts` berisi
  koordinat `x`, `y`, lebar, dan tinggi setiap tombol dalam satuan unit
  keycap. Aplikasi mengubahnya menjadi widget sehingga bentuk fisik papan
  tergambar tanpa mengunduh gambar apa pun.
- Pemilih varian susunan tombol untuk keyboard yang menyediakan lebih dari
  satu layout.
- Penyimpanan hasil permintaan di memori, sehingga membuka halaman yang sama
  dua kali tidak mengunduh ulang.
- Penanganan keadaan memuat, kosong, dan gagal, lengkap dengan tombol coba
  lagi ketika jaringan bermasalah.

## Struktur proyek

```
lib/
├── main.dart                        konfigurasi MaterialApp dan rute
├── theme.dart                       palet warna dan tipografi
├── model/
│   ├── keyboard_ringkas.dart        entri daftar, memecah folder jadi merek + model
│   └── keyboard_detail.dart         spesifikasi lengkap, denah, dan tombol
├── service/
│   └── qmk_api.dart                 permintaan HTTP dan penguraian JSON
├── view/
│   ├── daftar_keyboard_page.dart    halaman daftar
│   ├── detail_keyboard_page.dart    halaman detail
│   └── tentang_page.dart            halaman tentang
└── widget/
    ├── kartu_keyboard.dart          kartu daftar dan chip merek
    ├── denah_keyboard.dart          penggambar denah tombol
    └── status.dart                  tampilan memuat dan gagal
```

Seluruh permintaan jaringan terpusat di `lib/service/qmk_api.dart`, sehingga
halaman hanya berurusan dengan objek model, bukan dengan JSON mentah.

## Cara menjalankan

Dibutuhkan Flutter SDK 3.47 atau lebih baru.

```bash
git clone https://github.com/mug31/keebdex.git
cd keebdex
flutter pub get
flutter run
```

Sasaran utama aplikasi adalah Android. Sasaran Linux ikut disertakan pada
proyek agar tampilan dapat diperiksa dengan cepat di komputer saat
pengembangan (`flutter run -d linux`).

Aplikasi memerlukan koneksi internet karena seluruh datanya diambil dari API.
Izin `android.permission.INTERNET` sudah dideklarasikan di
`android/app/src/main/AndroidManifest.xml`.

Menjalankan pengujian unit:

```bash
flutter test
```

## Paket yang dipakai

| Paket | Versi | Kegunaan |
|---|---|---|
| `http` | ^1.5.0 | Permintaan GET ke QMK Keyboards API |
| `google_fonts` | ^9.0.0 | Huruf Inter untuk antarmuka dan JetBrains Mono untuk nilai teknis |
| `cupertino_icons` | ^1.0.8 | Set ikon bawaan |

## Lisensi data

Data keyboard milik proyek QMK Firmware dan para kontributornya, diakses
melalui API publik mereka. Aplikasi ini dibuat untuk keperluan akademik.
