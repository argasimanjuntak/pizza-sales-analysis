# pizza-sales-analysis
**Analisis penjualan pizza menggunakan SQL untuk mengevaluasi performa pendapatan, pertumbuhan bulanan, jam operasional puncak, performa menu dan ukuran, serta pemakaian bahan baku**

![Looker Studio](https://img.shields.io/badge/LOOKER_STUDIO-4285F4?style=for-the-badge&logo=looker&logoColor=white)
![Google BigQuery](https://img.shields.io/badge/GOOGLE_BIGQUERY-669DF6?style=for-the-badge&logo=googlecloud&logoColor=white)
![Microsoft Excel](https://img.shields.io/badge/MICROSOFT_EXCEL-217346?style=for-the-badge&logo=microsoftexcel&logoColor=white)
![Microsoft Word](https://img.shields.io/badge/MICROSOFT_WORD-2B579A?style=for-the-badge&logo=microsoftword&logoColor=white)
![Microsoft Office](https://img.shields.io/badge/MICROSOFT_OFFICE-D83B01?style=for-the-badge&logo=microsoftoffice&logoColor=white)
![GitHub](https://img.shields.io/badge/GITHUB-181717?style=for-the-badge&logo=github&logoColor=white)
![Markdown](https://img.shields.io/badge/MARKDOWN-000000?style=for-the-badge&logo=markdown&logoColor=white)

## 🗂️ Struktur Data & Skema Tabel

Dataset yang dianalisis mencakup data transaksi penjualan pizza selama satu tahun penuh yang terbagi ke dalam 4 tabel relasional utama:

| Nama Tabel | Deskripsi Isi | Kolom Utama (Key Attributes) |
| :--- | :--- | :--- |
| **`orders`** | Menyimpan informasi tingkat transaksi per pesanan. | `order_id`, `date`, `time` |
| **`order_details`** | Menyimpan rincian setiap item pizza yang dibeli dalam satu pesanan. | `order_details_id`, `order_id`, `pizza_id`, `quantity` |
| **`pizzas`** | Menyimpan katalog varian fisik pizza, ukuran, dan harga satuannya. | `pizza_id`, `pizza_type_id`, `size`, `price` |
| **`pizza_types`** | Menyimpan informasi master menu, pengelompokan kategori, dan daftar bahan baku. | `pizza_type_id`, `name`, `category`, `ingredients` |

---

### 🔗 Hubungan Antartabel (Data Relationships)
* **`orders.order_id` $\rightarrow$ `order_details.order_id`**: Menghubungkan waktu/tanggal transaksi dengan rincian item yang dibeli.
* **`pizzas.pizza_id` $\rightarrow$ `order_details.pizza_id`**: Menghubungkan item pesanan dengan ukuran (*size*) dan harga (*price*) spesifik.
* **`pizza_types.pizza_type_id` $\rightarrow$ `pizzas.pizza_type_id`**: Mengaitkan varian SKU pizza dengan kategori (*Classic, Supreme, Chicken, Veggie*) dan rincian bahan baku (*ingredients*).


  ## 📋 Daftar dan Cakupan Analisis SQL

Analisis ini mencakup 15 kueri SQL terstruktur untuk menjawab kebutuhan performa bisnis, pola transaksi harian, pergerakan menu, hingga pemakaian bahan baku:

### 1. Metrik Kinerja Utama & Periode Operasional
* **Performa Penjualan Keseluruhan:** Menghitung total pendapatan (*total sales*), total pesanan (*total orders*), jumlah pizza terjual (*total pizzas sold*), dan rata-rata nilai transaksi (*Average Order Value* / AOV).
* **Periode Aktif Toko:** Menghitung total hari aktif transaksi, rentang minggu ISO (*ISO weeks*), dan total bulan operasional.

### 2. Analisis Tren Waktu (Bulanan & Harian)
* **Pertumbuhan Penjalan Bulanan:** Menghitung total pendapatan per bulan beserta persentase perubahannya (*Month-over-Month growth*).
* **Faktor Pendorong Lonjakan Penjualan November:** Menganalisis kategori pizza yang menjadi penopang utama kenaikan pendapatan di bulan November.
* **Bulan Penjualan Terbaik:** Menentukan dua bulan dengan performa tertinggi berdasarkan pendapatan, jumlah pesanan, dan unit pizza terjual.
* **Kategori Teratas di Bulan Tertentu:** Mengetahui kategori dengan penjualan kuantitas tertinggi pada bulan Mei dan Juli.
* **Performa Penjualan Berdasarkan Hari:** Menghitung total pendapatan serta rata-rata harian untuk nilai omzet, jumlah pesanan, dan loyang pizza terjual per hari dalam sepekan (Senin–Minggu).

### 3. Analisis Jam Operasional & Jam Puncak
* **Pola Transaksi per Jam:** Menghitung total pesanan, loyang terjual, pendapatan, rata-rata harian, serta jumlah hari aktif yang dikelompokkan berdasarkan jam operasional.
* **Menu Terlaris Jam Puncak (Lunch & Dinner):** Menentukan tiga kombinasi varian pizza dan ukuran dengan kuantitas terbanyak pada jam makan siang dan jam makan malam.

### 4. Performa Kategori & Bauran Produk
* **Peringkat Kategori Berdasarkan Pesanan:** Mengurutkan kategori pizza berdasarkan banyaknya transaksi pesanan yang masuk.
* **Kombinasi Produk dan Ukuran Terlaris:** Mengetahui varian pizza beserta ukurannya yang terjual dalam kuantitas terbesar.
* **Produk dengan Pendapatan Terendah:** Mengidentifikasi menu pizza yang menghasilkan nilai penjualan paling kecil.
* **Produk Unggulan per Kategori:** Menentukan pizza penyumbang pendapatan terbesar pada masing-masing kategori.
* **Ukuran Pizza Terlaris per Kategori:** Mengidentifikasi ukuran pizza (S, M, L, XL) yang paling banyak terjual di tiap kategori.

### 5. Manajemen Bahan Baku
* **Frekuensi Pemakaian Bahan Makanan:** Mengurai string daftar resep (*flattens ingredients*) untuk menghitung seberapa sering masing-masing bahan baku digunakan dalam seluruh pesanan.
