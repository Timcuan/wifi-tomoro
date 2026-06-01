# Changelog

Semua perubahan penting pada proyek ini didokumentasikan di file ini.

Format mengikuti [Keep a Changelog](https://keepachangelog.com/id/1.0.0/), dan versi mengikuti [Semantic Versioning](https://semver.org/lang/id/).

## [2.5.0] - 2026-05-31

### Ditambahkan

- `lib/anim.sh` — spinner, progress bar animasi, brand reveal
- Menu layar alternatif (history terminal bersih)
- Hint kontekstual ON/OFF · toggle mekanisme dengan `?`
- Fokus pintar: ON jika mati, OFF jika aktif

### Diubah

- Intro `ingfo`: reveal brand + spinner
- Start: progress bar `█░` per langkah
- OFF dari menu: spinner tanpa header ganda

## [2.3.0] - 2026-05-31

### Ditambahkan

- Brand **INGFO TOMORO** — logo, `ingfo` sebagai CLI utama
- Menu interaktif **↑↓ Enter** + animasi intro (`lib/tui.sh`)
- `install.sh` — clone, symlink `~/.local/bin/ingfo`, progress animasi
- Progress bar pada langkah start

### Diubah

- `./ingfo` tanpa argumen → menu (bukan langsung start)
- `tomoro` tetap alias ke `ingfo`

## [2.2.0] - 2026-05-31

### Ditambahkan

- Rules SpoofDPI prioritas **crypto** (GMGN, DEX, CEX, wallet RPC) dengan TLS disorder
- `./tomoro test-crypto` — uji GMGN, Dexscreener, Binance, Jupiter, dll.
- Logika uji pintar: HTTP 403 Cloudflare = TLS OK (bukan blok ISP)
- [docs/CRYPTO.md](docs/CRYPTO.md) — evaluasi & panduan crypto/GMGN

## [2.1.0] - 2026-05-31

### Ditambahkan

- Mode **deep** (default): DoH, TLS disorder, fragment chunk, DNS publik sistem, IPv6 off, proxy di semua interface
- Mode **deep --ultra**: fake TLS packets (daemon SpoofDPI via sudo, paling agresif)
- Proxy **SOCKS5** paralel (port 1080) untuk aplikasi non-HTTP-proxy
- Perintah `./tomoro test` — verifikasi endpoint via proxy
- Dokumen [docs/KEAMANAN.md](docs/KEAMANAN.md) — lapisan perlindungan & batas teknis
- Backup/restore DNS per interface; log SpoofDPI di `.tomoro/spoofdpi.log`

### Diubah

- SpoofDPI memakai profil TOML + flag CLI selaras (dns-mode `https`)
- Start flow 5 langkah dengan perisai sistem macOS

### Diperbaiki

- Hindari `fake-count` default yang memicu error pcap tanpa root
- Pemulihan IPv6 dan DNS lebih andal (metadata SERVICE di backup)

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

[2.3.0]: https://github.com/Timcuan/wifi-tomoro/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/Timcuan/wifi-tomoro/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/Timcuan/wifi-tomoro/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/Timcuan/wifi-tomoro/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Timcuan/wifi-tomoro/releases/tag/v1.0.0
