# Lapisan perlindungan Wifi Tomoro

Dokumen ini menjelaskan **seberapa dalam** tool ini melawan pembatasan WiFi, dan batas teknisnya.

## Model ancaman

| Lapisan blokir ISP / WiFi | Mekanisme | Perlindungan Tomoro |
|---------------------------|-----------|---------------------|
| DNS poisoning / filter | Respon DNS palsu | DoH di SpoofDPI + DNS publik sistem (1.1.1.1, 8.8.8.8) di mode **deep** |
| DPI TLS (SNI) | Baca hostname di Client Hello | Fragmentasi + **disorder** paket TLS |
| HTTP redirect / block page | Halaman blokir | Proxy HTTP(S) sistem → SpoofDPI |
| IPv6 leak | Blokir hanya IPv4 | **IPv6 off** sementara di mode deep (dipulihkan saat stop) |
| Ganti interface | Proxy hanya di Wi-Fi aktif | **Semua interface** di-hard di mode deep |
| Aplikasi non-proxy | Abaikan proxy macOS | SOCKS5 tambahan (deep) + proxy HTTP/S |
| **GMGN / crypto** | DPI pada SNI DEX/CEX | **Rules crypto** + `./tomoro test-crypto` |

## Mode bypass

### `deep` (default)

Tanpa menjalankan daemon sebagai root:

- SpoofDPI: DoH, TLS **disorder**, fragment **chunk 35**
- macOS: proxy HTTP + HTTPS (+ SOCKS jika port bebas) di **semua** layanan jaringan
- DNS sistem → resolver publik (backup otomatis saat stop)
- IPv6 dimatikan sementara per interface

### `deep --ultra` atau `TOMORO_ULTRA=1`

Menambah **fake TLS packets** + chunk size 1 (paling agresif). Di macOS ini membutuhkan **sudo pada proses SpoofDPI** (akses paket). Jalankan hanya jika mode deep biasa belum cukup.

```bash
./tomoro start --ultra
# atau
TOMORO_ULTRA=1 ./tomoro start
```

### `standard`

DoH + fragment SNI klasik, proxy hanya pada **jaringan aktif** (hemat, lebih ringan).

```bash
./tomoro start --standard
```

## Verifikasi

```bash
./tomoro start
./tomoro test    # uji HTTPS via proxy lokal
./tomoro status  # lapisan & proxy aktif
```

## Batas (penting)

1. **Bukan VPN penuh** — hanya lalu lintas yang memakai proxy sistem / SOCKS. Aplikasi yang mengabaikan proxy macOS bisa tetap terblokir.
2. **Captive portal** hotel/kantor — tool ini untuk sensor DPI ISP, bukan halaman login WiFi.
3. **Mode ultra** butuh sudo pada daemon SpoofDPI (bukan hanya untuk `networksetup`).
4. **TUN mode** SpoofDPI (semua paket OS) masih eksperimental — belum diaktifkan default agar stabil & mudah dipulihkan.
5. **Hukum & kebijakan** — patuhi aturan jaringan setempat.

## Rekomendasi praktis

1. `./tomoro doctor`
2. `./tomoro start` (deep)
3. `./tomoro test`
4. Jika masih gagal: `./tomoro stop` lalu `./tomoro start --ultra`
5. Selalu `./tomoro stop` sebelum tinggalkan jaringan publik
