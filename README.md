# Wifi Tomoro

[![macOS](https://img.shields.io/badge/platform-macOS-blue)](https://www.apple.com/macos/)
[![CLI](https://img.shields.io/badge/cli-tomoro-cyan)](./tomoro)
[![SpoofDPI](https://img.shields.io/badge/powered%20by-SpoofDPI-orange)](https://github.com/xvzc/spoofdpi)

**Wifi Tomoro** adalah CLI untuk macOS yang membantu membuka akses internet di WiFi yang dibatasi (sensor DPI / halaman blokir ISP) — **tanpa VPN**. Cocok ketika **Cursor**, ChatGPT, Reddit, atau situs lain gagal terhubung di jaringan tertentu (mis. XL, IndiHome).

Semua binary dan state disimpan di folder proyek (`bin/`, `.tomoro/`). Tidak mengubah sistem Mac secara permanen.

---

## Fitur

- **Mode deep (default)** — DoH, TLS disorder, DNS publik, IPv6 off, proxy di semua interface, SOCKS5
- **Mode ultra** — fake TLS packets untuk DPI paling keras (`./tomoro start --ultra`)
- CLI **`tomoro`** — start, stop, status, **test**, doctor
- UI terminal — logo, langkah progres, kartu status
- Pulihkan proxy, DNS, IPv6 saat berhenti (`Ctrl+C` atau `stop`)

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
- Tunggu banner **PERISAI AKTIF**.
- **Biarkan terminal terbuka** selama dipakai.

### 3. Verifikasi bypass

```bash
./tomoro test
```

### 4. Uji aplikasi

Buka Cursor, browser, atau situs yang sebelumnya terblokir.

Masih gagal? Coba mode lebih agresif:

```bash
./tomoro stop
./tomoro start --ultra
```

### 5. Cek status (opsional)

```bash
./tomoro status
```

### 6. Matikan bypass

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
| `./tomoro test` | Verifikasi koneksi via proxy |
| `./tomoro start --ultra` | DPI paling agresif (sudo pada daemon) |
| `./tomoro start --standard` | Mode ringan |
| `./tomoro help` | Bantuan CLI |
| `./tomoro version` | Versi |

Port alternatif: `TOMORO_PORT=9090 ./tomoro start`

---

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| [docs/PANDUAN.md](docs/PANDUAN.md) | **Panduan lengkap** langkah demi langkah (ID) |
| [docs/KEAMANAN.md](docs/KEAMANAN.md) | Lapisan perlindungan & batas teknis |
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
flowchart TB
  subgraph macOS["macOS — mode deep"]
    P[Proxy HTTP/S + SOCKS semua interface]
    D[DNS 1.1.1.1 / 8.8.8.8]
    V[IPv6 off sementara]
  end
  subgraph local["Lokal"]
    S[SpoofDPI :8080 / :1080]
    H[DoH + TLS disorder + fragment]
  end
  P --> S
  S --> H
  H --> ISP[ISP / WiFi]
  D --> ISP
```

1. SpoofDPI: DoH + manipulasi TLS Client Hello (anti-DPI)
2. Proxy sistem + SOCKS menangkap traffic aplikasi
3. DNS publik + flush — hindari poisoning resolver ISP
4. Semua interface di-hard — tidak bocor saat ganti WiFi
5. `stop` / `Ctrl+C` mengembalikan DNS, IPv6, proxy

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
