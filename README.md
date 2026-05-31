# 📶 Wifi Tomoro: macOS Smart & Portable DPI Bypass 🚀

Repository ini berisi **Smart Script Portable** khusus macOS untuk melewati pemblokiran internet (sensor DPI / Internet Positif / XL Axiata Block Page) secara otomatis dan aman. 

Script ini dirancang khusus agar **sama sekali tidak merugikan pengguna ketika berpindah jaringan atau mematikan alat**, karena memiliki sistem pemantauan dinamis dan pemulihan proxy otomatis.

---

## ✨ Fitur Unggulan

* **🚀 100% Portable & Mandiri (Self-contained)**: Semua file binary (`SpoofDPI`) diunduh dan disimpan di dalam folder repositori (`bin/`). Tidak ada perubahan permanen di direktori sistem global Mac Anda.
* **🌐 Deteksi Arsitektur Otomatis**: Secara cerdas mengenali apakah Mac Anda menggunakan chip Apple Silicon (`arm64`/M1/M2/M3) atau Intel (`amd64`) dan mengunduh versi yang tepat.
* **🔄 Pelacak Jaringan Cerdas (Dynamic Network Tracking)**: 
  * Jika Anda berpindah jaringan (misalnya dari Wi-Fi Rumah ke Hotspot HP, atau menyambungkan kabel Ethernet), script akan mendeteksi perubahan ini dalam 3 detik.
  * Secara otomatis mematikan proxy di jaringan lama (agar internet tidak mati/macet) dan mengaktifkannya di jaringan yang baru aktif.
* **🧹 Pembersihan Aman Otomatis (Graceful Cleanup)**: Begitu Anda menghentikan script ini (menekan `Ctrl+C` atau menutup Terminal), semua pengaturan proxy sistem macOS akan **langsung dinonaktifkan** secara otomatis. Internet Anda tidak akan pernah macet setelah alat ini ditutup!

---

## 🛠 Cara Penggunaan

### 1. Kloning Repositori
Jika Anda belum mengkloning repositori ini:
```bash
git clone https://github.com/Timcuan/wifi-tomoro.git
cd wifi-tomoro
```

### 2. Jalankan Script
Cukup jalankan satu perintah berikut di Terminal Anda:
```bash
./start.sh
```

---

## 🔍 Cara Kerja Sistem

1. **Unduh Binary Lokal**: Pertama kali dijalankan, script memeriksa keberadaan binary `spoofdpi` di folder `bin/`. Jika tidak ada, script akan mengunduhnya langsung dari rilis resmi GitHub.
2. **Autentikasi Hak Akses**: Meminta kata sandi administrator (`sudo`) satu kali di awal untuk mendapatkan izin mengubah pengaturan Proxy Web macOS.
3. **Jalankan Daemon**: Memulai `spoofdpi` di latar belakang pada port lokal `8080`.
4. **Siklus Pemantauan (Monitoring Loop)**:
   * Setiap 3 detik, mengecek adapter jaringan aktif (misal `en0`).
   * Mengatur macOS HTTP & HTTPS Proxy di adapter tersebut ke `127.0.0.1:8080`.
   * Jika adapter berubah, script mematikan proxy di adapter lama dan mengaktifkannya di adapter baru.
5. **Pemulihan Saat Keluar**: Menangkap sinyal `Ctrl+C`, menghentikan proses `spoofdpi`, menonaktifkan semua konfigurasi proxy macOS, dan membersihkan cache DNS sistem.

---

## 💡 Mengapa Cursor Tidak Bisa Konek & Bagaimana Alat Ini Membantu?

Editor **Cursor** (serta ChatGPT/Copilot/Reddit) menggunakan API yang sering kali melewati filter keamanan atau dideteksi secara keliru oleh *Deep Packet Inspection (DPI)* milik ISP seperti XL Axiata dan IndiHome, sehingga handshaking TLS diputus secara sepihak (*Connection Reset*).

Dengan menjalankan `./start.sh`, paket data HTTP/HTTPS akan dimodifikasi sedikit di tingkat lokal (DPI Bypass) sehingga sensor ISP tidak dapat membacanya sebagai situs terlarang, memungkinkan **Cursor** dan situs-situs terblokir lainnya terhubung kembali secara instan dan 100% normal tanpa memerlukan VPN!
