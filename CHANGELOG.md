# Changelog

Semua perubahan penting pada proyek ini didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.0.0/), dan versi mengikuti [Semantic Versioning](https://semver.org/lang/id/).

## [2.0.0] - 2026-05-31

### Ditambahkan

- CLI **`./tomoro`** dengan perintah: `start`, `stop`, `status`, `install`, `doctor`, `version`, `help`
- Modul terpisah di `lib/` (`common`, `ui`, `network`, `spoofdpi`, `cleanup`)
- UI terminal: logo ASCII, langkah progres, kartu status, spinner unduhan
- State sesi di `.tomoro/` (PID, layanan proxy, port) untuk pemulihan aman
- **`./tomoro stop`** — pulihkan proxy jika terminal ditutup paksa
- **`./tomoro doctor`** — diagnosa lingkungan sebelum dipakai
- Dokumentasi: `docs/PANDUAN.md`, `docs/CLI.md`, `CHANGELOG.md`
- README dengan panduan langkah demi langkah

### Diubah

- `start.sh` menjadi wrapper tipis ke `./tomoro start`
- README disederhanakan dan ditautkan ke dokumentasi lengkap

### Diperbaiki

- Pemetaan interface jaringan macOS lebih andal
- Unduhan SpoofDPI dengan validasi ukuran file
- Deteksi port bentrok sebelum menjalankan daemon

## [1.0.0] - 2026-05-18

### Ditambahkan

- Skrip monolit `start.sh` untuk bypass DPI di macOS
- Unduhan otomatis SpoofDPI (Apple Silicon & Intel) ke `bin/`
- Pelacakan perubahan jaringan dan proxy dinamis
- Pembersihan otomatis saat `Ctrl+C` (proxy + DNS flush)

[2.0.0]: https://github.com/Timcuan/wifi-tomoro/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Timcuan/wifi-tomoro/releases/tag/v1.0.0
