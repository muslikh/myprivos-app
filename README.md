# MyPrivos App (Flutter)

Aplikasi mobile untuk sistem sekolah **MyPrivos / SMKN 1 Prigen**, mengonsumsi **REST API v2** (berbasis JWT) dari backend Laravel.

## Peran & Fitur
- **Siswa**: lihat nilai (DKN/rapor), jadwal pelajaran, status kelulusan, ajukan surat.
- **Guru/Pegawai**: daftar pegawai/GTK, catat kehadiran guru di kelas (manual, bukan GPS/QR).
- **Admin**: semua fitur di atas + UPJ (katalog, checkout, jurnal PKL, pinjam sarpras), Buku Tamu, Webmail, Berita (WordPress).

> Catatan: Presensi berbasis **GPS/QR sengaja tidak disertakan** sesuai permintaan (sudah tidak dipakai).

## Konfigurasi
Server URL diisi di layar **Login** (disimpan di perangkat). Arahkan ke domain backend, mis. `https://sekolah.sch.id`. Endpoint yang dipanggil berada di bawah `/api/v2`.

## Menjalankan
```bash
flutter pub get
flutter run                 # ke device/emulator
```

## Build APK
```bash
flutter build apk --release
# hasil: build/app/outputs/flutter-apk/app-release.apk
```

## Autentikasi
Login memanggil `POST /api/v2/auth/login` dengan field `username` (bisa diisi username/NISN/email) dan `password`. Respon berisi `token` (JWT) + `role`. Token dikirim sebagai header `Authorization: Bearer <token>` di semua request lain. Logout memanggil `POST /api/v2/auth/logout`.

---

## CI/CD — GitHub Actions

Workflow: `.github/workflows/flutter-build.yml` (di root repo). Jalan otomatis saat **push tag `v*`** (mis. `git tag v1.0.0 && git push origin v1.0.0`) atau manual via tab **Actions → Run workflow**.

Folder `android/` & `ios/` tidak dikomit — digenerate di CI oleh `flutter create .`.

### Android (APK + AAB) — siap pakai
- Tanpa setting apa pun: build **release ber-signing debug** → APK bisa diinstal untuk uji coba, otomatis dilampirkan ke **GitHub Release** saat rilis via tag.
- Untuk **signing rilis asli** (wajib bila mau ke Play Store), isi **Secrets** repo (Settings → Secrets and variables → Actions):
  - `ANDROID_KEYSTORE_BASE64` — keystore `.jks` yang di-`base64` (`base64 -w0 upload-keystore.jks`)
  - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`
  - Lalu di `android/app/build.gradle` tambahkan pembacaan `key.properties` + `signingConfigs` (template standar Flutter). Setelah itu AAB bisa diunggah ke Play Console (manual atau pakai action `r0adkll/upload-google-play`).

### iOS
- Di CI hanya build **`--no-codesign`** → artifact `Runner.app` **tidak bisa diinstal** ke device/TestFlight (hanya bukti build sukses).
- Untuk IPA yang bisa dipasang / TestFlight / App Store **wajib**: akun **Apple Developer Program**, sertifikat distribusi, dan provisioning profile. Lalu tambah langkah signing (mis. `apple-actions/import-codesign-certs` + `flutter build ipa --export-options-plist=...`) dan upload ke TestFlight (`apple-actions/upload-testflight-build` atau `fastlane pilot`).
- Alternatif lebih mudah untuk iOS: **Codemagic** (gratis terbatas) yang menangani signing otomatis.

### Opsi "deploy" selain GitHub Release
- **Firebase App Distribution** (bagus untuk bagi APK/IPA ke tester): tambah step `wzieba/Firebase-Distribution-Github-Action` dengan `FIREBASE_APP_ID` + token.
- **Google Play** (Android): `r0adkll/upload-google-play` + service account JSON.
- **TestFlight/App Store** (iOS): setelah signing beres.

---

## Auto-update (popup + unduh otomatis)

App mengecek `GET {server}/api/v2/app/version` saat masuk Home. Jika `latest_build` > build terpasang, muncul popup; tombol **Perbarui Sekarang** mengunduh APK (ota_update) dan memicu pemasangan.

Backend (Laravel) mengembalikan nilai dari `.env`:
```
APP_LATEST_VERSION=1.0.5
APP_LATEST_BUILD=5
APP_APK_URL=https://my.smkn1prigen.sch.id/app/my-privos.apk
APP_UPDATE_MANDATORY=false
APP_UPDATE_NOTES=Perbaikan login & ikon baru
```
- `APP_LATEST_BUILD` = nomor build rilis terbaru (samakan dengan `v1.0.<run>` dari Actions, mis. run 5 → 5).
- `APP_APK_URL` = lokasi APK yang bisa diunduh publik (unggah ke server, atau mirror dari Release). APK dari Release repo privat butuh auth, jadi host di server lebih mudah.
- Nama app: **My Privos**. Ikon: logo SMKN 1 Prigen.
