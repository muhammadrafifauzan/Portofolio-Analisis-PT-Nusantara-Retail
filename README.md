# Analisis Kinerja Penjualan B2B Nusantara Retail (2023)

📊 Live Dashboard
Dashboard Interaktif di Looker Studio
https://datastudio.google.com/reporting/40ee6258-b4f8-40cc-9a6a-82bca0b18f4f 
Sebuah proyek portofolio analisis data end-to-end yang berfokus pada evaluasi kinerja penjualan, performa *sales representative*, dan tren produk pada perusahaan ritel B2B "Nusantara Retail" selama tahun 2023.

Proyek ini bertujuan untuk menggali *actionable insights* dari data transaksi historis Nusantara Retail. Analisis difokuskan pada identifikasi *top performer* di tim sales, evaluasi realisasi target pendapatan, dan pemetaan kategori produk yang memberikan kontribusi *revenue* serta *gross profit* terbesar. Proyek ini mendemonstrasikan proses pembersihan data (Data Cleaning) dan analisis tingkat lanjut menggunakan SQL (Window Functions, CTEs, Aggregation).

# Struktur Repositori

nusantara-retail-sql/
│
├── analisis_nusantara.sql              # 10 query analisis utama
│
├── Dataset_CSV_NusantaraRetail/        # Dataset sumber (10 tabel CSV)
│   ├── transaksi_penjualan.csv         # 840 baris transaksi utama
│   ├── penjualan_harian.csv            # 365 baris data harian
│   ├── karyawan.csv                    # 119 karyawan
│   ├── customer.csv                    # 15 customer B2B
│   ├── produk.csv                      # 30 produk
│   ├── target_sales.csv                # 48 baris target per kategori
│   ├── gaji_summary.csv                # Hasil window function gaji
│   ├── tren_penjualan_bulanan.csv      # Tren MoM 12 bulan
│   ├── performa_sales.csv              # Ranking sales global
│   ├── penjualan_per_kategori_bulan.csv
│   └── README.txt                      # Panduan dataset
│
└── Output_Query_SQL/                   # Hasil eksekusi 10 query
    ├── Ranking performa sales perbulan.csv
    ├── high performer sales.csv
    ├── MoM growth per kategori.csv
    ├── identifikasi bulan terbaik & terburuk global.csv
    ├── running total penjualan harian.csv
    ├── moving average 7 hari + deteksi anomali.csv
    ├── hitung nilai RFM per customer.csv
    ├── ringkasan segmen customer.csv
    ├── top produk + running % kumulatif (pareto chart).csv
    └── perbandingan realisasi vs target per kategori.csv

# Dataset Overview

Dataset simulasi PT Nusantara Retail — perusahaan ritel B2B Indonesia, periode Januari–Desember 2023.
Tabel                        Baris         Deskripsi
transaksi_penjualan           840          Transaksi utama: produk, customer, sales, revenue, profit
penjualan_harian              365          Agregasi penjualan per hari + LAG, MA7, running total
karyawan                      119          Data SDM: jabatan, departemen, gaji, lama kerja  
customer                      15           Profil customer B2B: industri, tier, total pembelian
produk                        30           Katalog: kategori, harga, HPP, margin, stok
target_sales                  48           Target vs realisasi per kategori per bulan
gaji_summary                  119          Hasil RANK/DENSE_RANK/AVG per departemen (kolom verifikasi)
tren_penjualan_bulanan        12           Ringkasan bulanan: MoM growth, running total
performa_sales—Ranking sales  -            global berdasarkan total revenue
penjualan_per_kategori_bulan  48           Ranking kategori per bulan

# Window Functions yang Digunakan
Fungsi                                 Query         Kegunaan
DENSE_RANK()                           Q1, Q2        Ranking sales tanpa gap
RANK()                                 Q4, Q10       Ranking dengan gap
LAG()                                  Q3, Q4        Bandingkan dengan baris sebelumnya
LEAD()                                 Q4            Lihat baris berikutnya
SUM() OVER (ROWS UNBOUNDED PRECEDING)  Q5, Q9        Running total / kumulatif
AVG() OVER (ROWS N PRECEDING)          Q6            Moving average
NTILE(3)                               Q7, Q8        Bagi data ke N bucket
ROW_NUMBER()                           Q9            Nomor urut ranking

# Cara Menjalankan lewat Google BigQuery

Buat dataset bernama NusantaraRetail di project BigQuery kamu
Import file CSV ke tabel yang sesuai:

transaksi_penjualan.csv → tabel transaksi_penjualan
penjualan_harian.csv → tabel penjualan_harian
target_sales.csv → tabel target_sales
Jalankan query dari file analisis_nusantara.sql

# Dashboard Looker Studio
Dashboard mencakup visualisasi dari seluruh 10 analisis:

📊 Ranking sales per bulan (bar chart)
📉 MoM Growth per kategori (line chart)
🗺️ Running Total YTD (area chart)
🔍 Anomaly Detection harian
🎯 Realisasi vs Target per kategori
👥 Distribusi segmen customer RFM
🏆 Pareto Chart produk

# Tujuan Pembelajaran
Proyek ini dirancang sebagai latihan praktis untuk:

✅ Memahami konsep Window Functions secara mendalam
✅ Membedakan RANK, DENSE_RANK, ROW_NUMBER
✅ Menggunakan LAG/LEAD untuk analisis tren temporal
✅ Membuat running total dan moving average dengan Frame Clause
✅ Melakukan RFM Analysis dan Pareto Analysis dengan SQL murni
✅ Memvisualisasikan hasil query di Looker Studio

# Tech Stack

Database: Google BigQuery
Language: Standard SQL
Visualization: Google Looker Studio
Data Format: CSV

Author
Dibuat sebagai portofolio proyek analisis data dengan SQL Window Functions.

Dataset ini adalah data simulasi untuk keperluan pembelajaran. Tidak merepresentasikan data perusahaan nyata.
