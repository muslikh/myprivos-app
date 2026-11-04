import 'package:flutter/material.dart';
import 'siswa/nilai_screen.dart';
import 'siswa/jadwal_screen.dart';
import 'siswa/kelulusan_screen.dart';
import 'surat/surat_request_screen.dart';
import 'pegawai/pegawai_list_screen.dart';
import 'pegawai/presensi_kelas_screen.dart';
import 'upj/upj_items_screen.dart';
import 'upj/pkl_jurnal_screen.dart';
import 'upj/sarpras_pinjam_screen.dart';
import 'tamu/tamu_list_screen.dart';
import 'webmail/webmail_screen.dart';
import 'wordpress/berita_screen.dart';

class Feature {
  final String title;
  final IconData icon;
  final Color color;
  final String category;
  final Set<String> roles;
  final WidgetBuilder builder;
  const Feature(this.title, this.icon, this.color, this.category, this.roles, this.builder);
}

const _cAkademik = Color(0xFF1565C0);
const _cKepegawaian = Color(0xFF2E7D32);
const _cUpj = Color(0xFFEF6C00);
const _cAdmin = Color(0xFF6A1B9A);
const _cInfo = Color(0xFF00838F);

final List<Feature> kAllFeatures = [
  Feature('Nilai', Icons.grading, _cAkademik, 'Akademik', {'siswa', 'admin'}, (_) => const NilaiScreen()),
  Feature('Jadwal', Icons.calendar_month, _cAkademik, 'Akademik', {'siswa', 'guru', 'admin'}, (_) => const JadwalScreen()),
  Feature('Kelulusan', Icons.verified, _cAkademik, 'Akademik', {'siswa', 'admin'}, (_) => const KelulusanScreen()),
  Feature('Ajukan Surat', Icons.mail_outline, _cAdmin, 'Administrasi', {'siswa', 'admin'}, (_) => const SuratRequestScreen()),
  Feature('Pegawai / GTK', Icons.badge_outlined, _cKepegawaian, 'Kepegawaian', {'guru', 'admin'}, (_) => const PegawaiListScreen()),
  Feature('Kehadiran Kelas', Icons.co_present, _cKepegawaian, 'Kepegawaian', {'guru', 'admin'}, (_) => const PresensiKelasScreen()),
  Feature('Katalog UPJ', Icons.storefront, _cUpj, 'Teaching Factory', {'guru', 'admin'}, (_) => const UpjItemsScreen()),
  Feature('Jurnal PKL', Icons.menu_book, _cUpj, 'Teaching Factory', {'siswa', 'guru', 'admin'}, (_) => const PklJurnalScreen()),
  Feature('Pinjam Sarpras', Icons.handyman, _cUpj, 'Teaching Factory', {'guru', 'admin'}, (_) => const SarprasPinjamScreen()),
  Feature('Buku Tamu', Icons.how_to_reg, _cAdmin, 'Administrasi', {'admin', 'guru'}, (_) => const TamuListScreen()),
  Feature('Webmail', Icons.email, _cAdmin, 'Administrasi', {'admin'}, (_) => const WebmailScreen()),
  Feature('Berita Sekolah', Icons.newspaper, _cInfo, 'Informasi', {'siswa', 'guru', 'admin'}, (_) => const BeritaScreen()),
];

List<Feature> featuresFor(String role) =>
    kAllFeatures.where((f) => f.roles.contains(role)).toList();

/// Ordered category list, keeping only categories that have features for role.
List<String> categoriesFor(String role) {
  final feats = featuresFor(role);
  final seen = <String>[];
  for (final f in feats) {
    if (!seen.contains(f.category)) seen.add(f.category);
  }
  return seen;
}
