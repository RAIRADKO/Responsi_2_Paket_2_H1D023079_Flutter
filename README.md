# Responsi 2 - Paket 2 (Backend API)

Proyek ini adalah implementasi Backend API untuk manajemen inventaris barang menggunakan framework Laravel.

## 📌 Data Diri

* **Nama: Rahmat Irfan Adie Purwamoko**
* **NIM:** H1D023079
* **Shift Baru: D**
* **Shift Asal: B**

## 🎥 Video Demo Aplikasi

Link demo aplikasi dapat dilihat di tautan berikut:
**https://youtu.be/UtZRozqHh_Q**

---

## 🚀 Spesifikasi API

Berikut adalah dokumentasi endpoint API yang tersedia dalam aplikasi ini. Semua endpoint inventaris memerlukan autentikasi menggunakan Bearer Token (Sanctum).

### 1. Autentikasi (Authentication)

| Method | Endpoint | Deskripsi | Parameter Body (JSON) |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/register` | Mendaftarkan pengguna baru | `name` (string), `email` (string, unique), `password` (string, min:6) |
| `POST` | `/api/login` | Masuk ke sistem dan mendapatkan token | `email` (string), `password` (string) |

### 2. Inventaris (Inventory)

**Header Wajib:** `Authorization: Bearer <access_token>`

| Method | Endpoint | Deskripsi | Parameter Body (JSON) |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/inventories` | Mengambil semua data barang | - |
| `POST` | `/api/inventories` | Menambahkan barang baru | `name` (string), `price` (int), `quantity` (int), `entry_date` (date), `expiry_date` (date, after entry_date) |
| `GET` | `/api/inventories/{id}` | Mengambil detail barang berdasarkan ID | - |
| `PUT` | `/api/inventories/{id}` | Memperbarui data barang | `name` (string), `price` (int), `quantity` (int), `entry_date` (date), `expiry_date` (date, after entry_date) |
| `DELETE` | `/api/inventories/{id}` | Menghapus data barang | - |

---

## 💻 Penjelasan Kode

Berikut adalah penjelasan mengenai fungsi-fungsi utama yang digunakan dalam controller aplikasi ini.

### 🔐 AuthController
Menangani proses autentikasi pengguna.

* **`register(Request $request)`**
    * **Fungsi:** Mendaftarkan pengguna baru ke dalam sistem.
    * **Alur:** Memvalidasi input (`name`, `email`, `password`), membuat user baru di database dengan password yang di-hash menggunakan `Hash::make`, lalu membuat token autentikasi (Sanctum) dan mengembalikannya dalam respon JSON.

* **`login(Request $request)`**
    * **Fungsi:** Mengautentikasi pengguna yang sudah terdaftar.
    * **Alur:** Memvalidasi input, mencari user berdasarkan email, dan memverifikasi password menggunakan `Hash::check`. Jika cocok, sistem akan membuat token baru dan mengembalikannya. Jika salah, akan melempar `ValidationException`.

### 📦 InventoryController
Menangani operasi CRUD (Create, Read, Update, Delete) untuk data barang. Controller ini dilindungi oleh middleware `auth:sanctum`.

* **`index()`**
    * **Fungsi:** Menampilkan daftar semua barang.
    * **Alur:** Mengembalikan semua data dari tabel `inventories` menggunakan model `Inventory::all()`.

* **`store(Request $request)`**
    * **Fungsi:** Menyimpan data barang baru.
    * **Alur:** Memvalidasi input (memastikan tipe data benar dan tanggal kedaluwarsa setelah tanggal masuk). Jika valid, data disimpan menggunakan `Inventory::create($validated)` dan mengembalikan data barang yang baru dibuat dengan status 201.

* **`update(Request $request, $id)`**
    * **Fungsi:** Memperbarui data barang yang sudah ada.
    * **Alur:** Memvalidasi input sama seperti fungsi `store`. Mencari barang berdasarkan `$id` menggunakan `Inventory::findOrFail($id)`. Jika ditemukan, data diupdate dan respon JSON berisi data terbaru dikembalikan.

* **`destroy($id)`**
    * **Fungsi:** Menghapus data barang.
    * **Alur:** Mencari barang berdasarkan `$id`. Jika ditemukan, fungsi `delete()` dipanggil untuk menghapus data dari database. Mengembalikan respon kosong (null) dengan status 204.

### 🗄️ Database Migration (Inventories Table)
Struktur tabel `inventories` dirancang dengan kolom:
* `id`: Primary Key.
* `name`: Nama barang.
* `price`: Harga barang (integer).
* `quantity`: Jumlah stok (integer).
* `entry_date`: Tanggal barang masuk.
* `expiry_date`: Tanggal kedaluwarsa.
* `timestamps`: Kolom `created_at` dan `updated_at` otomatis dari Laravel.
