# INGFO TOMORO

[![macOS](https://img.shields.io/badge/platform-macOS-blue)](https://www.apple.com/macos/)
[![CLI](https://img.shields.io/badge/cli-ingfo-cyan)](./ingfo)
[![SpoofDPI](https://img.shields.io/badge/powered%20by-SpoofDPI-orange)](https://github.com/xvzc/spoofdpi)

**INGFO TOMORO** — CLI interaktif untuk macOS: buka akses internet di WiFi terbatas (DPI / blokir ISP) tanpa VPN. GMGN, crypto, Cursor, ChatGPT, dan situs terblokir lain.

Menu interaktif (**↑↓ + Enter**), instalasi satu perintah, tampilan teks rapi tanpa ASCII art.

---

## Instalasi mudah

### Satu baris (disarankan)

```bash
curl -fsSL https://raw.githubusercontent.com/Timcuan/wifi-tomoro/main/install.sh | bash
```

Lalu tambahkan PATH (jika installer mengingatkan):

```bash
echo 'export PATH="${HOME}/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

### Manual

```bash
git clone https://github.com/Timcuan/wifi-tomoro.git ~/ingfo-tomoro
cd ~/ingfo-tomoro
chmod +x ingfo tomoro install.sh
./install.sh
```

---

## Mulai — menu ON / OFF

```bash
ingfo
```

Hanya dua kontrol + penjelasan mekanisme di layar:

| Menu | Fungsi |
|------|--------|
| **ON** | Nyalakan bypass (deep) — terminal ini harus tetap terbuka |
| **OFF** | Matikan bypass, kembalikan proxy & DNS Mac |

Atau tanpa menu:

```bash
ingfo on    # nyalakan
ingfo off   # matikan
```

| Tombol | Aksi |
|--------|------|
| **↑ ↓** | Pilih ON atau OFF |
| **Enter** | Jalankan |
| **q** | Keluar |

Mekanisme lengkap: [docs/MEKANISME.md](docs/MEKANISME.md)

---

## Perintah cepat (tanpa menu)

| Perintah | Fungsi |
|----------|--------|
| `ingfo` | Menu interaktif |
| `ingfo start` | Aktifkan perisai (deep) |
| `ingfo start --ultra` | DPI paling keras |
| `ingfo stop` | Matikan & pulihkan Mac |
| `ingfo status` | Status bypass |
| `ingfo test-crypto` | Uji GMGN & crypto |
| `ingfo doctor` | Diagnosa sistem |

`tomoro` = alias `ingfo`

---

## Langkah pertama

1. `ingfo` → pilih **Aktifkan perisai**
2. Masukkan password Mac (`sudo`)
3. Biarkan terminal terbuka
4. Terminal lain: `ingfo test-crypto`
5. Selesai: **Ctrl+C** atau `ingfo stop`

---

## Dokumentasi

| File | Isi |
|------|-----|
| [docs/MEKANISME.md](docs/MEKANISME.md) | Cara kerja ON/OFF |
| [docs/PANDUAN.md](docs/PANDUAN.md) | Panduan lengkap |
| [docs/CRYPTO.md](docs/CRYPTO.md) | GMGN & crypto |
| [docs/KEAMANAN.md](docs/KEAMANAN.md) | Lapisan perlindungan |
| [docs/CLI.md](docs/CLI.md) | Referensi perintah |
| [CHANGELOG.md](CHANGELOG.md) | Riwayat versi |

---

## Repo

https://github.com/Timcuan/wifi-tomoro
