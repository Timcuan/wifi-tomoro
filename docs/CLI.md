# Referensi CLI — Wifi Tomoro

## Sintaks

```bash
./tomoro [perintah]
```

Tanpa perintah → sama dengan `start`.

## Perintah

| Perintah | Alias | Deskripsi |
|----------|-------|-----------|
| `start` | `run`, *(kosong)* | Aktifkan bypass + loop pelacakan jaringan |
| `stop` | `off` | Matikan SpoofDPI, nonaktifkan proxy, flush DNS |
| `status` | `st` | Status bypass dan proxy jaringan aktif |
| `install` | `setup` | Unduh/ekstrak SpoofDPI ke `bin/` saja |
| `doctor` | `check` | Diagnosa macOS, dependensi, port, jaringan |
| `version` | `-v`, `--version` | Tampilkan versi |
| `help` | `-h`, `--help` | Bantuan di terminal |

## Variabel lingkungan

| Variabel | Default | Fungsi |
|----------|---------|--------|
| `TOMORO_PORT` | `8080` | Port proxy lokal SpoofDPI |

Contoh:

```bash
TOMORO_PORT=9090 ./tomoro start
```

## File state (`.tomoro/`)

| File | Isi |
|------|-----|
| `run.pid` | PID proses SpoofDPI |
| `services` | Daftar layanan macOS yang pernah di-set proxy |
| `port` | Port yang dipakai sesi terakhir |

Folder ini diabaikan git; aman dihapus saat bypass tidak aktif (`./tomoro stop`).

## Kode keluar

| Kode | Arti |
|------|------|
| `0` | Sukses |
| `1` | Error (lingkungan, unduhan, port, proses mati) |

## Kompatibilitas

```bash
./start.sh    # → ./tomoro start
```
