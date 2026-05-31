# Wifi Tomoro

[![macOS](https://img.shields.io/badge/platform-macOS-blue)](https://www.apple.com/macos/)
[![CLI](https://img.shields.io/badge/cli-tomoro-cyan)](./tomoro)
[![SpoofDPI](https://img.shields.io/badge/powered%20by-SpoofDPI-orange)](https://github.com/xvzc/spoofdpi)

**Wifi Tomoro** adalah CLI untuk macOS yang membantu membuka akses internet di WiFi yang dibatasi (sensor DPI / halaman blokir ISP) — **tanpa VPN**. Cocok ketika **Cursor**, ChatGPT, Reddit, atau situs lain gagal terhubung di jaringan tertentu (mis. XL, IndiHome).

Semua binary dan state disimpan di folder proyek (`bin/`, `.tomoro/`). Tidak mengubah sistem Mac secara permanen.

---

## Fitur

- CLI **`tomoro`** — perintah jelas: start, stop, status, doctor
- UI terminal — logo, langkah progres, kartu status
- Unduh SpoofDPI otomatis (Apple Silicon & Intel)
- Lacak ganti WiFi/hotspot (~3 detik)
- Pulihkan proxy & DNS saat berhenti (`Ctrl+C` atau `stop`)

---

## Persyaratan

- macOS 11+
- `curl`, `sudo`, Terminal
- Koneksi internet (unduhan pertama)

---

## Instalasi

```bash
git clone https://github.com/Timcuan/wifi-tomoro.git
cd wifi-tomoro
chmod +x tomoro start.sh
```

---

## Penggunaan — langkah demi langkah

### 1. Cek lingkungan (disarankan pertama kali)

```bash
./tomoro doctor
```

Pastikan item penting berstatus ✓.

### 2. Aktifkan bypass

```bash
./tomoro start
```

- Masukkan **password Mac** saat diminta (`sudo`).
- Tunggu banner **BYPASS AKTIF**.
- **Biarkan terminal terbuka** selama dipakai.

### 3. Uji koneksi

Buka Cursor, browser, atau situs yang sebelumnya terblokir.

### 4. Cek status (opsional)

```bash
./tomoro status
```

### 5. Matikan bypass

**Di terminal yang sama:**

```bash
# Tekan Ctrl+C
```

**Atau dari terminal lain:**

```bash
./tomoro stop
```

---

## Perintah cepat

| Perintah | Fungsi |
|----------|--------|
| `./tomoro` | Aktifkan bypass |
| `./tomoro stop` | Matikan & pulihkan sistem |
| `./tomoro status` | Cek status |
| `./tomoro doctor` | Diagnosa |
| `./tomoro install` | Unduh SpoofDPI saja |
| `./tomoro help` | Bantuan CLI |
| `./tomoro version` | Versi |

Port alternatif: `TOMORO_PORT=9090 ./tomoro start`

---

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| [docs/PANDUAN.md](docs/PANDUAN.md) | **Panduan lengkap** langkah demi langkah (ID) |
| [docs/CLI.md](docs/CLI.md) | Referensi perintah & variabel |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat perubahan versi |

---

## Masalah umum

| Gejala | Solusi |
|--------|--------|
| Internet macet setelah tutup terminal | `./tomoro stop` |
| Port 8080 bentrok | `TOMORO_PORT=9090 ./tomoro start` |
| SpoofDPI belum terunduh | `./tomoro install` |

Detail: [docs/PANDUAN.md §8](docs/PANDUAN.md#8-masalah-umum)

---

## Cara kerja (ringkas)

```mermaid
flowchart LR
  A[./tomoro start] --> B[SpoofDPI :8080]
  B --> C[Proxy macOS]
  C --> D[Traffic ke ISP]
  D --> E[DPI bypass]
```

1. SpoofDPI berjalan di `127.0.0.1:8080`
2. Proxy HTTP/HTTPS macOS diarahkan ke proxy lokal
3. Paket dimodifikasi agar sensor ISP tidak memutus TLS
4. Saat ganti jaringan, proxy dipindah otomatis
5. Saat `stop` / `Ctrl+C`, semua dikembalikan

---

## Struktur proyek

```
wifi-tomoro/
├── tomoro          # CLI utama
├── start.sh        # Alias → tomoro start
├── lib/            # Modul bash
├── docs/           # Panduan & referensi
├── bin/            # SpoofDPI (gitignored, diunduh otomatis)
└── .tomoro/        # State sesi (gitignored)
```

---

## Kredit & lisensi

- [SpoofDPI](https://github.com/xvzc/spoofdpi) — Apache 2.0
- Wifi Tomoro — wrapper & otomasi proxy macOS

Gunakan sesuai hukum dan kebijakan jaringan di wilayah Anda.
