# Portofolio-Analisis-PT-Nusantara-Retail
# 📊 Analisis Kinerja Penjualan B2B Nusantara Retail (2023)

Sebuah proyek portofolio analisis data end-to-end yang berfokus pada evaluasi kinerja penjualan, performa *sales representative*, dan tren produk pada perusahaan ritel B2B "Nusantara Retail" selama tahun 2023.

## 📝 Deskripsi Proyek
Proyek ini bertujuan untuk menggali *actionable insights* dari data transaksi historis Nusantara Retail. Analisis difokuskan pada identifikasi *top performer* di tim sales, evaluasi realisasi target pendapatan, dan pemetaan kategori produk yang memberikan kontribusi *revenue* serta *gross profit* terbesar. Proyek ini mendemonstrasikan proses pembersihan data (Data Cleaning) dan analisis tingkat lanjut menggunakan SQL (Window Functions, CTEs, Aggregation).

## 🛠️ Tools & Teknologi
* **Microsoft Excel / Google Sheets:** Eksplorasi awal dan Validasi Kualitas Data (Data Profiling).
* **SQL (Google BigQuery):** Pemrosesan data tingkat lanjut, manipulasi, dan ekstraksi *insight* bisnis.

## 📂 Struktur Repositori
* `analisis_nusantara.sql`: Kumpulan *query* SQL utama yang digunakan untuk menjawab berbagai pertanyaan bisnis.
* `NusantaraRetail_DataClean.xlsx - transaksi_penjualan.csv`: Dataset utama yang berisi riwayat 840 transaksi penjualan B2B.
* `NusantaraRetail_DataClean.xlsx - Sheet1.csv`: Laporan hasil *data profiling* dan metrik kebersihan dataset.

## 📊 Gambaran Dataset (Data Profiling)
Berdasarkan proses validasi awal, dataset ini terbukti bersih dan siap untuk dianalisis:
* **Total Baris Data:** 840 transaksi (Periode Januari - Desember 2023).
* **Missing Values (NULL):** 0 pada semua kolom kritis.
* **Duplikasi:** 0 baris duplikat (Setiap `No_transaksi` unik).
* **Konsistensi Bisnis:** Tidak ditemukan anomali nilai (seperti *quantity* atau *total penjualan* bernilai negatif/nol).
* **Cakupan Bisnis:** Melibatkan 15 Perusahaan B2B aktif dan mencakup 4 kategori produk utama (Elektronik, Furniture, ATK, Konsumsi).

## 🔍 Objektif Analisis (SQL Queries)
File SQL di dalam repositori ini dirancang untuk menjawab pertanyaan bisnis strategis, antara lain:
1. **Sales Performance:** Siapa saja *sales representative* terbaik di tiap bulannya dan siapa yang paling konsisten berada di Top 3?
2. **Product Profitability:** Produk dan kategori mana yang menyumbang *revenue* dan persentase kumulatif tertinggi bagi perusahaan?
3. **Target Achievement:** Bagaimana perbandingan antara target penjualan dengan realisasi aktual tiap bulannya? Kategori mana yang meleset dari target?

## 🚀 Cara Penggunaan
1. Unduh atau *clone* repositori ini.
2. *Import* file `transaksi_penjualan.csv` ke dalam *database* SQL Anda (disesuaikan dengan *schema* `NusantaraRetail.transaksi_penjualan` yang ada di dalam *script*).
3. Jalankan *query* yang terdapat di dalam file `analisis_nusantara.sql` secara berurutan pada platform SQL pilihan Anda (direkomendasikan Google BigQuery atau PostgreSQL).

---
*Proyek ini dikembangkan sebagai bagian dari portofolio Data Analytics untuk menunjukkan kemampuan dalam pengolahan basis data relasional dan ekstraksi wawasan bisnis.*
