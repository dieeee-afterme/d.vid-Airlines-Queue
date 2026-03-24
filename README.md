# ✈️ D.VID Airlines Queue & Immigration System

![FiveM](https://img.shields.io/badge/FiveM-Ready-orange.svg)
![Lua](https://img.shields.io/badge/Language-Lua-blue.svg)
![Version](https://img.shields.io/badge/Version-5.0.0-success.svg)

Selamat datang di **D.VID Airlines**, sistem antrean (Queue) dan Imigrasi tingkat lanjut untuk server FiveM Anda. Didesain khusus untuk server skala besar (*scale-up*) yang membutuhkan keamanan ekstra tanpa mengorbankan estetika UI (*User Interface*).

Ubah layar antrean yang membosankan menjadi pengalaman *boarding* pesawat kelas dunia! 🌍✈️

---

## ✨ Fitur Unggulan (First Class Features)

🎫 **Interactive Flight Boarding UI** Menggunakan UI *Adaptive Card* bawaan FiveM dengan animasi *progress bar* pesawat terbang yang bergerak secara *real-time* (`🛫 ➖➖✈️➖➖ 🛬`) mengikuti posisi antrean pemain.

🛂 **Immigration Check (Anti-Spoofer & Anti-Bypass)** Sistem keamanan ketat yang menolak pemain tanpa identitas yang jelas. Memeriksa keberadaan *Rockstar License*, koneksi Steam, integrasi Discord, dan *Hardware Token* asli untuk memblokir *Spoofer*.

📡 **Weather Radar (Anti-VPN & Proxy)** Terintegrasi langsung dengan API pencegah VPN untuk memblokir penumpang gelap yang mencoba masuk menggunakan *IP Masking* atau VPN.

🪪 **Passport Control (Name Validator)** Mencegah *troll* atau *bocil* masuk menggunakan nama profil yang tidak valid (mengandung simbol aneh atau nama yang terlalu pendek).

🌟 **Priority Miles (Discord Role Integration)** Sistem prioritas VIP berbasis *Role Discord*. Semakin tinggi *Role* pemain, semakin cepat mereka naik ke pesawat (mendapatkan poin tambahan). Mendukung fitur *Whitelist-Only*.

📹 **CCTV Bandara (Advanced Webhook Logs)** Admin dapat memantau log secara *real-time* melalui Discord Webhook. Sistem akan mencatat siapa saja yang berhasil *Takeoff*, dan siapa saja yang ditendang karena terdeteksi VPN/Spoofer lengkap beserta IP aslinya.

---

## ⚙️ Persyaratan (Dependencies)
- `oxmysql` (Untuk menyimpan data sesi terbang dan poin prioritas)

---

## 🛠️ Cara Pemasangan (Installation Guide)

1. **Unduh/Clone** repository ini dan letakkan di dalam folder `resources` server FiveM Anda.
2. Ubah nama folder menjadi `D.VID` (jika belum).
3. Buka file `config.lua` dan sesuaikan pengaturan berikut:
   - `Config.ServerName` dan `Config.Banner`
   - `Config.DiscordToken` (Masukkan token bot Discord Anda)
   - `Config.GuildId` (ID Server Discord Anda)
   - URL Webhook di bagian `Config.Webhooks`
4. Tambahkan baris kode berikut ke dalam file `server.cfg` Anda:
   ```text
   ensure oxmysql
   ensure D.VID
