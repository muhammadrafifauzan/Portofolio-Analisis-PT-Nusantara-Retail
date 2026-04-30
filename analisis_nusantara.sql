-- ================================================================
-- QUERY 1: Ranking performa sales per bulan
-- Tujuan: Siapa sales terbaik di setiap bulan?
-- Window Function: DENSE_RANK() OVER PARTITION BY bulan
-- ================================================================
WITH monthly_sales AS (
    SELECT
        bulan,
        bulan_num,
        sales_nip,
        nama_sales,
        COUNT(*)              AS jumlah_transaksi,
        SUM(total_penjualan)  AS total_revenue,
        SUM(qty)              AS total_qty
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY bulan, bulan_num, sales_nip, nama_sales
)
SELECT
    bulan,
    nama_sales,
    total_revenue,
    jumlah_transaksi,
    DENSE_RANK() OVER (
        PARTITION BY bulan_num
        ORDER BY total_revenue DESC
    ) AS rank_bulan_ini,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (PARTITION BY bulan_num), 1)
    AS pct_revenue_bulan
FROM monthly_sales
ORDER BY bulan_num, rank_bulan_ini;

-- ============================================================
-- QUERY 2: Siapa sales yang KONSISTEN di Top 3 setiap bulan?
-- Tujuan: Identifikasi high-performer yang andal
-- ============================================================
WITH monthly_rank AS (
    SELECT
        sales_nip, nama_sales, bulan_num,
        SUM(total_penjualan) AS monthly_rev,
        DENSE_RANK() OVER (
            PARTITION BY bulan_num ORDER BY SUM(total_penjualan) DESC
        ) AS dr
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY sales_nip, nama_sales, bulan_num
)
SELECT
    nama_sales,
    COUNT(*) AS total_bulan_aktif,
    SUM(CASE WHEN dr <= 3 THEN 1 ELSE 0 END) AS bulan_di_top3,
    ROUND(SUM(CASE WHEN dr <= 3 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 0) AS pct_top3
FROM monthly_rank
GROUP BY sales_nip, nama_sales
HAVING bulan_di_top3 >= 3
ORDER BY pct_top3 DESC;

-- QUERY 3: MoM Growth per kategori menggunakan LAG()
-- Tujuan: Identifikasi tren naik/turun setiap kategori
-- Window Function: LAG() OVER PARTITION BY kategori
-- ============================================================

WITH monthly_cat AS (
    SELECT
        bulan_num,
        bulan,
        kategori,
        SUM(total_penjualan) AS revenue_bulan_ini
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY bulan_num, bulan, kategori
)
SELECT
    bulan,
    kategori,
    revenue_bulan_ini,
    LAG(revenue_bulan_ini) OVER (
        PARTITION BY kategori
        ORDER BY bulan_num
    ) AS revenue_bulan_lalu,
    revenue_bulan_ini - LAG(revenue_bulan_ini) OVER (
        PARTITION BY kategori ORDER BY bulan_num
    ) AS selisih_mom,
    ROUND(
        (revenue_bulan_ini - LAG(revenue_bulan_ini) OVER (PARTITION BY kategori ORDER BY bulan_num))
        * 100.0
        / LAG(revenue_bulan_ini) OVER (PARTITION BY kategori ORDER BY bulan_num),
        1
    ) AS growth_mom_pct,
    CASE
        WHEN revenue_bulan_ini > LAG(revenue_bulan_ini) OVER (PARTITION BY kategori ORDER BY bulan_num)
            THEN "NAIK"
        WHEN revenue_bulan_ini < LAG(revenue_bulan_ini) OVER (PARTITION BY kategori ORDER BY bulan_num)
            THEN "TURUN"
        ELSE "STABIL"
    END AS tren
FROM monthly_cat
ORDER BY bulan_num, kategori;

-- =====================================================
-- QUERY 4: Bandingkan setiap bulan dengan bulan sebelumnya
-- dan bulan berikutnya (LEAD) untuk konteks tren
-- =====================================================

WITH bulanan AS (
    SELECT
        bulan_num,
        bulan,
        SUM(total_penjualan) AS revenue
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY bulan_num, bulan
)
SELECT
    bulan,
    revenue,
    LAG(revenue) OVER (ORDER BY bulan_num) AS bulan_lalu,
    LEAD(revenue) OVER (ORDER BY bulan_num) AS bulan_depan,
    revenue - LAG(revenue) OVER (ORDER BY bulan_num) AS delta_vs_lalu,
    RANK() OVER (ORDER BY revenue DESC) AS rank_terbaik,
    RANK() OVER (ORDER BY revenue ASC) AS rank_terburuk
FROM bulanan
ORDER BY bulan_num;

-- ================================================================
-- QUERY 5: Kumulatif (Running Total) penjualan harian
-- Tujuan: Lihat progress Year-to-Date setiap hari
-- Frame Clause: ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
-- ================================================================
SELECT  
    tanggal,  
    hari,  
    bulan,  
    kuartal,  
    total_penjualan,  
    SUM(total_penjualan) OVER (  
        ORDER BY tanggal  
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  
    ) AS running_total_ytd,  
    ROUND(  
        SUM(total_penjualan) OVER (  
            ORDER BY tanggal  
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  
        ) * 100.0  
        / SUM(total_penjualan) OVER ()  
    , 1) AS pct_ytd  
FROM `NusantaraRetail.penjualan_harian`  
ORDER BY tanggal;

-- ================================================================
-- QUERY 6: Moving Average 7 hari + Anomaly Detection
-- Tujuan: Temukan hari dengan penjualan JAUH dari tren normal
-- Frame Clause: ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
-- ================================================================
SELECT
    tanggal,
    hari,
    bulan,
    total_penjualan,
    ROUND(
        AVG(total_penjualan) OVER (
            ORDER BY tanggal
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ),
        0
    ) AS moving_avg_7hari,
    CASE
        WHEN total_penjualan > AVG(total_penjualan) OVER (
            ORDER BY tanggal
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) * 1.3 THEN 'ANOMALI_POSITIF'
        WHEN total_penjualan < AVG(total_penjualan) OVER (
            ORDER BY tanggal
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) * 0.7 THEN 'ANOMALI_NEGATIF'
        ELSE 'NORMAL'
    END AS status_penjualan
FROM `NusantaraRetail.penjualan_harian` 
ORDER BY tanggal;

-- ================================================================
-- QUERY 7: RFM Analysis untuk segmentasi customer
-- ================================================================
WITH rfm_raw AS (
    SELECT
        kode_customer,
        nama_customer,
        -- Recency: berapa hari sejak pembelian terakhir
        DATE_DIFF(DATE("2023-12-31"), MAX(DATE(tanggal)), DAY) AS recency_hari,
        -- Frequency: berapa kali transaksi
        COUNT(DISTINCT id) AS frequency,
        -- Monetary: total pembelian
        SUM(total_penjualan) AS monetary
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY kode_customer, nama_customer
)
SELECT
    nama_customer,
    recency_hari,
    frequency,
    monetary,
    -- Skor RFM: 3 = terbaik, 1 = terburuk
    NTILE(3) OVER (ORDER BY recency_hari ASC) AS r_score,   -- ASC: recency kecil = lebih baik
    NTILE(3) OVER (ORDER BY frequency DESC) AS f_score,
    NTILE(3) OVER (ORDER BY monetary DESC) AS m_score,
    -- Segmen berdasarkan kombinasi skor
    CASE
        WHEN NTILE(3) OVER (ORDER BY monetary DESC) = 3 THEN "Champion"
        WHEN NTILE(3) OVER (ORDER BY monetary DESC) = 2 THEN "Loyal Customer"
        ELSE "Needs Attention"
    END AS segmen_customer
FROM rfm_raw
ORDER BY monetary DESC;

-- ================================================================
-- QUERY 8: Ringkasan per segmen customer (untuk dashboard)
-- ================================================================
WITH rfm AS (
    SELECT
        nama_customer,
        monetary,
        CASE
            WHEN NTILE(3) OVER (ORDER BY monetary DESC) = 3 THEN "Champion"
            WHEN NTILE(3) OVER (ORDER BY monetary DESC) = 2 THEN "Loyal Customer"
            ELSE "Needs Attention"
        END AS segmen
    FROM (
        SELECT
            kode_customer,
            nama_customer,
            SUM(total_penjualan) AS monetary
        FROM `NusantaraRetail.transaksi_penjualan`
        GROUP BY kode_customer, nama_customer
    )
)
SELECT
    segmen,
    COUNT(*) AS jumlah_customer,
    SUM(monetary) AS total_revenue_segmen,
    ROUND(AVG(monetary)) AS avg_revenue_per_customer,
    ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER(), 1) AS pct_dari_total
FROM rfm
GROUP BY segmen
ORDER BY total_revenue_segmen DESC;

-- ================================================================
-- QUERY 9: Analisis Pareto – 80% revenue dari berapa produk?
-- Menggunakan Running Total untuk hitung kumulatif %
-- ================================================================
WITH produk_rev AS (
    SELECT
        nama_produk,
        kategori,
        SUM(qty) AS total_qty,
        SUM(total_penjualan) AS total_revenue,
        SUM(gross_profit) AS total_profit
    FROM `NusantaraRetail.transaksi_penjualan`
    GROUP BY nama_produk, kategori
)
SELECT
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS urutan,
    nama_produk,
    kategori,
    total_qty,
    total_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 1) AS pct_revenue,
    ROUND(
        SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / SUM(total_revenue) OVER (),
        1
    ) AS kumulatif_pct
FROM produk_rev
ORDER BY total_revenue DESC;

-- ================================================================
-- QUERY 10: Realisasi vs Target – kategori mana yang meleset?
-- JOIN antara tabel transaksi dan tabel target
-- ================================================================
SELECT
    t.bulan,
    t.no_bulan,
    t.kategori_produk,
    t.target,
    t.realisasi,
    t.realisasi - t.target AS selisih,
    ROUND(t.realisasi * 100.0 / t.target, 1) AS pct_capaian,
    t.status,
    -- Ranking capaian dalam bulan ini
    RANK() OVER (
        PARTITION BY t.no_bulan
        ORDER BY (t.realisasi * 1.0 / t.target) DESC
    ) AS rank_capaian_bulan_ini
FROM `NusantaraRetail.target_sales` t
ORDER BY t.no_bulan, rank_capaian_bulan_ini;


