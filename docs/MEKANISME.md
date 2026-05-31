# Mekanisme INGFO TOMORO

Penjelasan singkat cara tool ini membuka akses di WiFi yang dibatasi.

## Masalah di WiFi terbatas

| Yang dilakukan jaringan | Akibat |
|-------------------------|--------|
| **DPI** membaca SNI di TLS | Koneksi ke Cursor, ChatGPT, GMGN, dll. diputus |
| **DNS** diblokir atau dipalsukan | Situs tidak resolve / salah IP |
| **Halaman blokir** HTTP | Redirect ke warning ISP |

INGFO TOMORO menangani **DPI + DNS** di Mac Anda. Bukan pengganti VPN penuh.

## Alur saat ON

```text
[Aplikasi: Browser, Cursor, …]
        |
        v
[Proxy sistem macOS]  HTTP/HTTPS/SOCKS -> 127.0.0.1:8080 (dan :1080)
        |
        v
[SpoofDPI lokal]
  - DNS over HTTPS (DoH)
  - Pecah / acak urutan paket TLS (anti-SNI)
  - Rules khusus domain crypto / GMGN
        |
        v
[Internet / WiFi]  Sensor DPI tidak melihat SNI utuh
```

Langkah teknis otomatis:

1. Unduh / jalankan **SpoofDPI** di folder proyek (`bin/`).
2. Set **proxy HTTP + HTTPS** (dan SOCKS) di semua interface jaringan Mac.
3. Set **DNS** ke resolver publik (backup disimpan untuk restore).
4. **IPv6** dimatikan sementara agar tidak bocor lewat jalur lain.
5. Loop tiap ~3 detik: jika Anda ganti WiFi, pengaturan dipindah ke interface baru.

## Alur saat OFF

1. Proxy sistem dimatikan di semua interface yang pernah disentuh.
2. DNS dikembalikan dari backup (atau DHCP).
3. IPv6 dikembalikan ke otomatis.
4. Proses SpoofDPI dihentikan.
5. Cache DNS di-flush.

Mac kembali seperti sebelum bypass.

## Kontrol pengguna

| Aksi | Perintah |
|------|----------|
| Menu | `ingfo` |
| ON | `ingfo on` atau pilih **ON** di menu |
| OFF | `ingfo off` atau pilih **OFF** di menu |

Saat ON: **jangan tutup** terminal yang menjalankan bypass.  
OFF dari terminal lain tetap bisa: `ingfo off`.

## Batas

- Bukan VPN — app yang **tidak** pakai proxy macOS bisa tetap blokir.
- Captive portal hotel/kantor — bukan target tool ini.
- Geo-block situs (kebijakan negara) — tidak bisa diatasi hanya dengan DPI bypass.

Detail lapisan: [KEAMANAN.md](./KEAMANAN.md)
