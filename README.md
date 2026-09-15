# pizza-sales-analysis
**End-to-end pizza sales analysis using SQL, uncovering revenue trends, peak operational hours, product mix performance, and ingredient utilization.**

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
