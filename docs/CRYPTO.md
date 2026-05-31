# Crypto & GMGN — evaluasi bypass

## Apa yang dicek

Wifi Tomoro melindungi akses **crypto** dari blokir WiFi/ISP (DPI, DNS filter), bukan dari kebijakan situs itu sendiri.

| Gejala | Penyebab | Tomoro bantu? |
|--------|----------|---------------|
| Halaman tidak load, connection reset | DPI / ISP block TLS (SNI) | **Ya** — rules crypto + mode deep |
| DNS tidak resolve / IP salah | DNS poisoning ISP | **Ya** — DoH + DNS 1.1.1.1/8.8.8.8 |
| HTTP 403 + header `cloudflare` / `cf-mitigated` | Cloudflare challenge/WAF | **Sebagian** — TLS sudah lewat; selesaikan di **browser** |
| Situs blokir negara (geo) | Kebijakan exchange | **Tidak** — perlu VPN/residen lain |

## Situs yang dilindungi (rules SpoofDPI)

Prioritas bypass TLS **disorder + chunk** untuk:

- **GMGN** — `gmgn.ai`, `*.gmgn.ai`, `*.gmgn.cc`, WebSocket `wss://*.gmgn.ai`
- **DEX / data** — Dexscreener, Birdeye, Jupiter, Pump.fun, Raydium, Uniswap
- **Data harga** — CoinGecko, CoinMarketCap
- **CEX** — Binance, OKX, Bybit, Gate, MEXC, KuCoin
- **Wallet / RPC** — MetaMask, WalletConnect, Helius, Alchemy, Infura, Solana

Daftar lengkap: `lib/crypto.sh`

## Cara uji

```bash
./tomoro start
./tomoro test-crypto
```

### Membaca hasil

| Hasil test | Arti |
|------------|------|
| ✓ HTTP 200/301 | Sempurna via proxy |
| ! TLS OK · CF/WAF (403) | **Normal untuk GMGN/Dexscreener di curl** — buka di Chrome/Safari |
| ✗ tidak terjangkau | Masih kena block — coba `./tomoro start --ultra` |

**GMGN:** curl sering dapat 403 karena Cloudflare bot check. Selama browser bisa load chart/wallet setelah `./tomoro start`, bypass WiFi **berhasil**.

## Langkah jika GMGN masih gagal di browser

1. `./tomoro status` — pastikan AKTIF
2. `./tomoro test-crypto` — semua endpoint TLS terjangkau (boleh 403 CF)
3. `./tomoro stop && ./tomoro start --ultra`
4. Hard refresh browser (Cmd+Shift+R) atau private window
5. Pastikan tidak ada VPN lain bentrok

## Keamanan (bukan blokir)

- Tomoro **tidak** mengubah transaksi blockchain
- Proxy lokal hanya di Mac Anda; hentikan dengan `./tomoro stop` di WiFi publik
- Tetap waspadai phishing — bypass hanya jalan jaringan, bukan verifikasi situs
