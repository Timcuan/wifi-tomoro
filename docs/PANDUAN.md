# Panduan INGFO TOMORO — Langkah demi Langkah

**INGFO TOMORO** membantu membuka akses internet di WiFi yang dibatasi di macOS. Gunakan menu interaktif `ingfo` (↑↓ Enter) atau perintah langsung.

---

## Daftar isi

1. [Persiapan](#1-persiapan)
2. [Instalasi proyek](#2-instalasi-proyek)
3. [Cek lingkungan (doctor)](#3-cek-lingkungan-doctor)
4. [Aktifkan bypass](#4-aktifkan-bypass)
5. [Gunakan sehari-hari](#5-gunakan-sehari-hari)
6. [Matikan bypass](#6-matikan-bypass)
7. [Pindah WiFi / hotspot](#7-pindah-wifi--hotspot)
8. [Masalah umum](#8-masalah-umum)

---

## 1. Persiapan

Pastikan Anda memiliki:

| Item | Keterangan |
|------|------------|
| macOS | Tool **tidak** mendukung Windows/Linux |
| Terminal | Bawaan macOS (`Terminal.app` atau iTerm) |
| Koneksi internet | Untuk unduhan SpoofDPI pertama kali |
| Hak admin | Password Mac untuk `sudo` (atur proxy sistem) |

---

## 2. Instalasi proyek

### Langkah 2.1 — Clone & install

```bash
curl -fsSL https://raw.githubusercontent.com/Timcuan/wifi-tomoro/main/install.sh | bash
```

Atau manual:

```bash
git clone https://github.com/Timcuan/wifi-tomoro.git
cd wifi-tomoro
./install.sh
```

### Langkah 2.2 — Beri izin eksekusi (jika manual)

```bash
chmod +x ingfo tomoro install.sh
```

### Langkah 2.3 — (Opsional) Pasang di PATH

Agar bisa memanggil dari folder mana saja:

```bash
echo 'export PATH="$PATH:/path/ke/wifi-tomoro"' >> ~/.zshrc
source ~/.zshrc
```

Ganti `/path/ke/wifi-tomoro` dengan lokasi clone Anda.

---

## 3. Cek lingkungan (doctor)

Sebelum bypass pertama, jalankan diagnosa:

```bash
./tomoro doctor
```

Anda harus melihat tanda **✓** untuk macOS, perintah sistem, dan port. Jika SpoofDPI belum ada, itu normal — akan diunduh saat `start`.

---

## 4. Aktifkan bypass

### Langkah 4.1 — Menu atau start

```bash
ingfo
```

Pilih **Aktifkan perisai** dengan ↑↓ lalu Enter.

Atau langsung:

```bash
ingfo start
```

### Langkah 4.2 — Masukkan password

macOS meminta **password administrator** sekali (`sudo`) agar proxy sistem bisa diatur.

### Langkah 4.3 — Tunggu banner sukses

Terminal menampilkan kotak hijau **BYPASS AKTIF**. Contoh alur:

```
▸ Langkah 1/4 — Siapkan SpoofDPI
▸ Langkah 2/4 — Izin administrator (sudo)
▸ Langkah 3/4 — Jalankan proxy lokal
▸ Langkah 4/4 — Lacak jaringan & aktifkan bypass

╭──────────────────────────────────────────╮
│  ✓  BYPASS AKTIF — internet ... normal   │
╰──────────────────────────────────────────╯
```

### Langkah 4.4 — Biarkan terminal terbuka

Jangan tutup jendela Terminal selama bypass dipakai. Menutup paksa bisa meninggalkan proxy aktif — lihat [Langkah 6](#6-matikan-bypass).

### Langkah 4.5 — Uji akses

Buka browser atau **Cursor** — situs yang sebelumnya gagal (ChatGPT, Reddit, dll.) seharusnya bisa diakses.

---

## 5. Gunakan sehari-hari

| Tindakan | Perintah |
|----------|----------|
| Cek masih jalan? | `./tomoro status` |
| Port 8080 bentrok | `TOMORO_PORT=9090 ./tomoro start` |
| Unduh ulang SpoofDPI | `./tomoro install` |
| Bantuan singkat | `./tomoro help` |
| Versi tool | `./tomoro version` |

---

## 6. Matikan bypass

### Cara A — Terminal yang sama (disarankan)

Tekan **`Ctrl+C`** di terminal tempat `./tomoro start` berjalan. Proxy dan DNS akan dipulihkan otomatis.

### Cara B — Terminal lain

Jika jendela start sudah ditutup:

```bash
cd wifi-tomoro
./tomoro stop
```

Masukkan password `sudo` jika diminta.

---

## 7. Pindah WiFi / hotspot

Tidak perlu restart manual. Selama `./tomoro start` masih berjalan:

1. Anda pindah dari WiFi A ke WiFi B (atau hotspot).
2. Tool mendeteksi perubahan dalam ~3 detik.
3. Proxy di WiFi A dimatikan, proxy di WiFi B diaktifkan.

Pesan di terminal: `Jaringan: Wi-Fi` (atau nama layanan Anda).

---

## 8. Masalah umum

### Internet macet setelah tutup Terminal

```bash
./tomoro stop
```

### `Port 8080 sudah dipakai`

```bash
TOMORO_PORT=9090 ./tomoro start
```

### SpoofDPI gagal diunduh

- Periksa koneksi internet / firewall
- Coba: `./tomoro install`
- Jalankan lagi: `./tomoro doctor`

### Bypass sudah jalan (duplikat)

```bash
./tomoro status
./tomoro stop
./tomoro start
```

### Cursor masih tidak konek

1. Pastikan `./tomoro status` menunjukkan **AKTIF**
2. Coba flush: hentikan lalu start ulang bypass
3. Pastikan tidak ada VPN lain yang bentrok

---

## Bantuan lebih lanjut

- Referensi perintah: [CLI.md](./CLI.md)
- Ringkasan proyek: [README.md](../README.md)
- Riwayat versi: [CHANGELOG.md](../CHANGELOG.md)
