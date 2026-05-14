# AGENTS.md - DriveEase

## Deskripsi Project

DriveEase adalah aplikasi mobile rentcar berbasis Flutter untuk melihat katalog mobil, mencari mobil berdasarkan nama atau kategori, melihat detail mobil, serta mengelola data pendukung seperti user, kategori, dan katalog sesuai role pengguna.

Project mobile berada di:

```text
C:\PAM Lanjut\ucp2_paml
```

Backend API berada di:

```text
C:\PAM Lanjut\project_ucp\api_paml
```

Backend adalah aplikasi NestJS yang berjalan di:

```text
http://localhost:3000
```

State management utama aplikasi mobile harus menggunakan BLoC.

## Prinsip Implementasi Mobile

- Gunakan Flutter dengan arsitektur yang memisahkan presentation, business logic, data source, repository, dan model.
- Semua state async seperti loading, success, empty, dan error harus dimodelkan melalui BLoC/Cubit.
- Jangan panggil HTTP API langsung dari widget. Widget hanya berinteraksi dengan BLoC.
- Token JWT hasil login disimpan secara lokal dan dikirim melalui header `Authorization: Bearer <token>` untuk endpoint yang membutuhkan autentikasi.
- Base URL API dibuat terpusat agar mudah diganti antara emulator, device fisik, dan production.
- Untuk Android emulator gunakan `http://10.0.2.2:3000`. Untuk device fisik gunakan IP lokal komputer backend, bukan `localhost`.
- Gambar katalog diambil dari endpoint static asset: `http://localhost:3000/public/{filename}` atau base URL yang sesuai environment.

## Struktur Aplikasi yang Disarankan

```text
lib/
  main.dart
  core/
    constants/
    network/
    storage/
    theme/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    katalog/
      data/
      domain/
      presentation/
    kategori/
      data/
      domain/
      presentation/
    user/
      data/
      domain/
      presentation/
```

Struktur tiap feature:

```text
feature_name/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
  presentation/
    bloc/
    pages/
    widgets/
```

## Design System

### Identitas Visual

- Nama aplikasi: DriveEase
- Karakter visual: modern, bersih, mudah dipakai, dan terasa seperti aplikasi operasional rental kendaraan.
- Gaya UI: Material Design, layout rapi, fokus ke katalog kendaraan dan aksi pemesanan/pengelolaan.

### Warna

Gunakan warna secara konsisten melalui `ThemeData`.

- Primary: `#1565C0` untuk tombol utama, app bar, active state, dan elemen penting.
- Secondary: `#00A896` untuk status tersedia, aksen positif, dan badge.
- Background: `#F6F8FB` untuk latar halaman.
- Surface: `#FFFFFF` untuk card, bottom sheet, dan dialog.
- Text Primary: `#1F2937`
- Text Secondary: `#6B7280`
- Error: `#D32F2F`
- Warning: `#F9A825`
- Disabled: `#CBD5E1`

### Tipografi

- Gunakan font bawaan Flutter/Material kecuali project menambahkan font khusus.
- Heading besar: 24-28, bold.
- Heading section: 18-20, semibold.
- Body: 14-16, regular.
- Caption/helper text: 12-13.
- Hindari teks panjang di tombol. Gunakan label singkat seperti `Login`, `Simpan`, `Tambah`, `Hapus`.

### Komponen UI

- Button utama: filled button dengan warna primary.
- Button sekunder: outlined button.
- Card katalog: gambar mobil, nama, harga, kategori, status tersedia/tidak tersedia.
- Badge status:
  - Tersedia: secondary/green.
  - Tidak tersedia: warning/error.
- Input field: border radius 8, label jelas, validasi error tampil di bawah field.
- App bar: judul halaman dan action icon bila diperlukan.
- Bottom navigation atau navigation rail dapat digunakan untuk menu utama user.
- Empty state harus memberi pesan singkat dan aksi yang relevan.
- Error state harus menyediakan tombol `Coba Lagi`.

### Spacing dan Radius

- Base spacing: 8.
- Padding halaman: 16.
- Gap antar section: 16-24.
- Radius card/input/button: 8-12.
- Hindari card bersarang yang membuat layout berat.

## Backend dan Endpoint

Base URL development:

```text
http://localhost:3000
```

Static image URL:

```text
GET /public/{filename}
```

Sebagian besar endpoint dilindungi JWT oleh global `AuthGuard`. Endpoint yang jelas public saat ini hanya:

```text
POST /auth/login
```

Header untuk request authenticated:

```text
Authorization: Bearer <access_token>
```

### Root

| Method | Endpoint | Auth | Deskripsi |
| --- | --- | --- | --- |
| GET | `/` | Ya | Health/welcome message API. |

Response:

```json
{
  "message": "Ni API v1 gueh ya, welcome yeah "
}
```

### Auth

| Method | Endpoint | Auth | Body | Deskripsi |
| --- | --- | --- | --- | --- |
| POST | `/auth/login` | Tidak | JSON | Login user dan mendapatkan JWT. |

Body:

```json
{
  "email": "user@email.com",
  "password": "password123"
}
```

Success status: `202 Accepted`

Success response:

```json
{
  "access_token": "jwt_token"
}
```

Error login:

```json
{
  "message": "Email atau password salah"
}
```

### User

Role yang tersedia di entity backend:

- `superadmin`
- `admin`
- `member`

| Method | Endpoint | Auth | Role | Body | Deskripsi |
| --- | --- | --- | --- | --- | --- |
| POST | `/user` | Ya | Belum dibatasi di controller | JSON | Membuat user baru. |
| GET | `/user` | Ya | Superadmin | - | Mengambil semua user. |
| GET | `/user/:id` | Ya | Semua user authenticated | - | Mengambil detail user by id. |
| GET | `/user/search/:nama` | Ya | Semua user authenticated | - | Mencari user by nama/email. |
| PATCH | `/user/:id` | Ya | Semua user authenticated | JSON | Update user. |
| DELETE | `/user/:id` | Ya | Semua user authenticated | - | Hapus user. |

Body create user:

```json
{
  "email": "user@email.com",
  "firstName": "Budi",
  "lastName": "Santoso",
  "password": "password123",
  "role": "member"
}
```

Catatan:

- Password minimal 8 karakter.
- Email harus valid.
- `firstName` minimal 3 karakter.
- Response list user tidak mengembalikan password.

### Kategori

| Method | Endpoint | Auth | Role | Body | Deskripsi |
| --- | --- | --- | --- | --- | --- |
| POST | `/kategori` | Ya | Admin/Superadmin | JSON | Membuat kategori. |
| GET | `/kategori` | Ya | Semua user authenticated | - | Mengambil semua kategori. |
| GET | `/kategori/:id` | Ya | Semua user authenticated | - | Mengambil kategori by id. |
| GET | `/kategori/search/:nama` | Ya | Semua user authenticated | - | Mencari kategori by nama. |
| PATCH | `/kategori/:id` | Ya | Admin/Superadmin | JSON | Update kategori. |
| DELETE | `/kategori/:id` | Ya | Admin/Superadmin | - | Hapus kategori. |

Body create kategori:

```json
{
  "kategori": "SUV"
}
```

Validasi:

- `kategori` wajib diisi.
- Minimal 3 karakter.
- Harus string.

### Katalog

Katalog merepresentasikan mobil yang disewakan.

| Method | Endpoint | Auth | Body | Deskripsi |
| --- | --- | --- | --- | --- |
| POST | `/katalog` | Ya | multipart/form-data | Membuat katalog mobil dengan upload gambar. |
| GET | `/katalog` | Ya | - | Mengambil semua katalog. |
| GET | `/katalog/:id` | Ya | - | Mengambil katalog by id. |
| GET | `/katalog/:nama` | Ya | - | Mencari katalog by nama. |
| GET | `/katalog/:kategori` | Ya | - | Mencari katalog by kategori. |
| PATCH | `/katalog/:id` | Ya | multipart/form-data | Update katalog dan opsional gambar. |
| DELETE | `/katalog/:id` | Ya | - | Hapus katalog dan file gambar. |

Body create katalog memakai `multipart/form-data`:

```text
nama: string
harga: number
status: boolean optional
kategoriId: number
file: image file, wajib
```

Body update katalog memakai `multipart/form-data`:

```text
nama: string optional
harga: number optional
status: boolean optional
kategoriId: number optional
file: image file optional
```

Model katalog:

```json
{
  "id": 1,
  "nama": "Toyota Avanza",
  "harga": 350000,
  "status": true,
  "path": "1715600000000-123456789.jpg",
  "kategori": {
    "id": 1,
    "kategori": "MPV"
  }
}
```

Catatan penting untuk katalog:

- Controller backend saat ini memiliki route yang bentrok: `GET /katalog/:id`, `GET /katalog/:nama`, dan `GET /katalog/:kategori` memakai pola path yang sama. Secara NestJS, route pertama yang cocok dapat mengambil request sebelum route lain. Client sebaiknya mengutamakan `GET /katalog` dan filter di aplikasi sampai backend menyediakan path yang eksplisit seperti `/katalog/search/:nama` dan `/katalog/kategori/:id`.
- `harga` disimpan sebagai decimal di backend. Di Flutter, parsing perlu toleran terhadap response number atau string.
- File gambar wajib saat create katalog.
- Field upload bernama `file`.

## Fitur Aplikasi

### Fitur Member/User

- Splash screen atau initial auth check.
- Login.
- Home dashboard berisi ringkasan katalog dan kategori.
- List katalog mobil.
- Search katalog mobil.
- Filter katalog berdasarkan kategori.
- Detail katalog mobil.
- Tampilan harga sewa per hari.
- Status mobil tersedia/tidak tersedia.
- Logout.

### Fitur Admin/Superadmin

- Semua fitur member.
- Manajemen katalog:
  - tambah mobil.
  - edit mobil.
  - upload/update gambar mobil.
  - hapus mobil.
- Manajemen kategori:
  - tambah kategori.
  - edit kategori.
  - hapus kategori.
- Manajemen user:
  - lihat daftar user.
  - tambah user.
  - edit user.
  - hapus user.

### Fitur State yang Wajib Ada

Untuk setiap BLoC/Cubit data remote, minimal siapkan state:

- Initial
- Loading
- Success/Loaded
- Empty
- Error

Untuk form, minimal siapkan state:

- Initial
- Submitting
- Success
- Failure

## BLoC yang Disarankan

```text
AuthBloc
- login
- logout
- check saved token

KatalogBloc
- fetch all katalog
- refresh katalog
- search/filter katalog
- fetch detail katalog

KatalogFormBloc atau KatalogFormCubit
- create katalog
- update katalog
- delete katalog

KategoriBloc
- fetch kategori
- search kategori

KategoriFormBloc atau KategoriFormCubit
- create kategori
- update kategori
- delete kategori

UserBloc
- fetch users
- search user
- fetch user detail

UserFormBloc atau UserFormCubit
- create user
- update user
- delete user
```

## Model Data Mobile

### Auth

```dart
class LoginRequest {
  final String email;
  final String password;
}

class LoginResponse {
  final String accessToken;
}
```

### User

```dart
class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
}
```

### Kategori

```dart
class KategoriModel {
  final int id;
  final String kategori;
}
```

### Katalog

```dart
class KatalogModel {
  final int id;
  final String nama;
  final num harga;
  final bool status;
  final String path;
  final KategoriModel? kategori;
}
```

## Navigasi

Rute minimum:

```text
/splash
/login
/home
/katalog
/katalog/detail
/katalog/form
/kategori
/kategori/form
/user
/user/form
```

Menu utama yang disarankan:

- Home
- Katalog
- Kategori
- Profile

Untuk admin/superadmin tambahkan akses:

- Kelola Katalog
- Kelola Kategori
- Kelola User

## Validasi dan Error Handling

- Tampilkan validasi form di sisi mobile sebelum request.
- Login:
  - email wajib valid.
  - password minimal 8 karakter.
- Kategori:
  - nama kategori minimal 3 karakter.
- Katalog:
  - nama minimal 3 karakter.
  - harga wajib angka positif.
  - kategori wajib dipilih.
  - gambar wajib saat tambah katalog.
- Tampilkan pesan error dari API bila tersedia.
- Jika token tidak valid atau expired, arahkan kembali ke login.

## Catatan Integrasi Backend Saat Ini

- API memakai global `AuthGuard`, sehingga semua endpoint selain `POST /auth/login` dianggap butuh JWT.
- Payload JWT dari backend saat ini berisi `userId`, `firstName`, `lastName`, dan `email`. Role guard mengecek `request.user.role`, tetapi role belum dimasukkan ke payload token. Jika endpoint role admin/superadmin gagal walau user benar, backend perlu menambahkan `role` ke payload login.
- `POST /user` tidak diberi decorator public, jadi registrasi dari mobile tidak bisa dilakukan tanpa token kecuali backend diubah.
- `KategoriService.update()` saat ini memanggil dirinya sendiri sehingga berpotensi recursive error. Jika fitur update kategori gagal, perbaikan perlu dilakukan di backend.
- Route pencarian/filter katalog perlu dibuat lebih eksplisit di backend untuk menghindari konflik route.
- `Like(nama)` di backend tidak otomatis memakai wildcard. Jika ingin pencarian partial, backend perlu memakai `%${nama}%`.

## Dependency Flutter yang Kemungkinan Dibutuhkan

Tambahkan hanya saat mulai implementasi, bukan di dokumen ini:

```yaml
flutter_bloc
equatable
dio
shared_preferences
image_picker
cached_network_image
intl
go_router
```

## Target Kualitas

- UI responsif untuk layar kecil dan besar.
- State BLoC mudah dites.
- Tidak ada business logic berat di widget.
- Semua endpoint dan base URL dikelola dari satu tempat.
- Loading, empty, dan error state harus terlihat jelas.
- Form admin harus tetap usable ketika request gagal.
