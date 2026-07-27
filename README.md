# 🔄 Estafet - Digital Shift Handover System

**Estafet** adalah prototipe aplikasi iOS berbasis SwiftUI yang dirancang khusus untuk mendigitalisasi proses serah terima giliran kerja (*shift handover*) di industri berisiko tinggi dengan operasional 24/7, seperti Pertambangan, Minyak & Gas (Migas), dan Manufaktur. 

Aplikasi ini menggantikan buku log (catatan kertas) tradisional di ruang kontrol dengan sistem digital terpusat guna memastikan tidak ada informasi krusial terkait kondisi mesin yang terputus antara kru *shift* siang dan malam.

---

## ✨ Fitur Utama

### 🔐 1. Role-Based Access Control (RBAC) Cerdas
Sistem otentikasi otomatis mengenali peran pengguna berdasarkan Nomor ID pekerja yang dimasukkan:
* **Supervisor / Mandor**: Login menggunakan ID berawalan `SPV` (contoh: `SPV-01`). Akan diarahkan ke *Dashboard Command Center* untuk memantau seluruh aktivitas.
* **Operator / Mekanik**: Login menggunakan ID standar (contoh: `OP-12`). Akan diarahkan ke *Portal Operator* untuk membaca dan membuat log mesin.

### 👷‍♂️ 2. Portal Operator (Mobile App)
* **Acknowledge System (Tanda Tangan Digital):** Operator yang baru masuk *shift* diwajibkan membaca dan menekan tombol "Terima & Mulai Giliran" pada laporan *shift* sebelumnya. Ini memastikan akuntabilitas informasi.
* **Form Pelaporan Cepat:** Pembuatan log kondisi mesin di akhir *shift* dengan 3 indikator visual yang jelas:
  * 🟢 **Normal (Aman)**
  * 🟠 **Perlu Perhatian (Warning)**
  * 🔴 **Rusak (Breakdown)**
* **Riwayat Mesin:** *Logbook* digital yang mencatat riwayat kerusakan dan perpindahan tanggung jawab mesin antar operator.

### 📊 3. Dashboard Supervisor
* **Real-time Overview:** Menampilkan metrik *live* berapa banyak mesin yang sedang berstatus "Bermasalah" (Breakdown/Warning) dan berapa log yang "Menunggu" dibaca oleh operator selanjutnya.
* **Global Stream Log:** Tampilan log dari seluruh unit kerja yang memudahkan mandor mengambil keputusan pemeliharaan (*maintenance*).

---

## 🛠 Teknologi yang Digunakan

* **Framework UI:** SwiftUI
* **State Management:** Combine & `@EnvironmentObject` (Pola Arsitektur MVVM)
* **Ikonografi:** SF Symbols (Native iOS)
* **Minimum Target:** iOS 16.0+ (Karena menggunakan arsitektur `NavigationStack` modern)

---

## 🚀 Cara Menjalankan & Menguji Aplikasi

Karena seluruh kode disatukan dalam satu file `ContentView.swift` untuk mempermudah prototipe cepat, ikuti langkah berikut:

1. Buka **Xcode** (Versi 14.0 atau lebih baru).
2. Buat project baru: **File > New > Project...** lalu pilih **iOS App**.
3. Pastikan *Interface* disetel ke **SwiftUI**.
4. Buka file `ContentView.swift` di *Project Navigator*.
5. **Hapus seluruh isi** dari `ContentView.swift` bawaan Xcode.
6. **Salin dan Tempel (Copy-Paste)** seluruh kode *Estafet* ke dalam file tersebut.
7. Tekan **Cmd + R** atau klik tombol *Play* untuk menjalankan aplikasi di iOS Simulator.

### 🔑 Kredensial Pengujian (Login)

Aplikasi tidak menggunakan *database* sungguhan untuk login, melainkan mendeteksi **awalan ID Pekerja** Anda.

**Test sebagai Supervisor (Akses Dashboard):**
* **Nama Lengkap:** *Bebas (Contoh: Mandor Budi)*
* **ID Pekerja:** Wajib berawalan **SPV** *(Contoh: SPV-01, SPV-99)*

**Test sebagai Operator (Akses Form & Acknowledge):**
* **Nama Lengkap:** *Bebas (Contoh: Rian Mekanik)*
* **ID Pekerja:** Bebas selain SPV *(Contoh: OP-123, MCH-90)*

> **Tips Uji Coba Cepat:** 
> 1. Login sebagai Operator (`OP-12`).
> 2. Anda akan melihat layar merah berbunyi "Tindakan Diperlukan". Ini adalah simulasi serah terima dari operator sebelumnya. Tekan **Terima & Mulai Giliran**.
> 3. Pindah ke tab **Buat Laporan**, laporkan mesin rusak.
> 4. Pergi ke tab **Profil**, lalu *Logout*.
> 5. Login kembali sebagai Supervisor (`SPV-01`) dan lihat bagaimana laporan Anda tadi otomatis masuk ke layar *Dashboard Mandor*.

---

## 📂 Struktur Kode

Aplikasi ini dibagi dalam beberapa bagian (MARK) agar mudah dibaca:
1. `MARK: MODEL DATA`: Mendefinisikan struktur data `HandoverLog` dan *enum* `MachineCondition`.
2. `MARK: VIEW MODEL`: `EstafetViewModel` yang menangani logika *login*, persetujuan log, dan pengiriman form.
3. `MARK: ROOT VIEW`: Mengatur navigasi dan pergantian layar berdasarkan status *login* dan *role*.
4. `MARK: HALAMAN LOGIN`: Antarmuka autentikasi.
5. `MARK: PORTAL OPERATOR`: Tampilan 3 Tab untuk pekerja lapangan.
6. `MARK: DASHBOARD SUPERVISOR`: Tampilan ringkasan operasional untuk mandor.
7. `MARK: KOMPONEN UMUM`: Bagian UI yang dipakai berulang seperti `MachineBadge`.

---
*Estafet - Memastikan transisi aman, kelancaran operasional, dan nyawa terlindungi di setiap pergantian waktu.*
