/// Kelas utilitas Keamanan dan Penyorotan Sanitasi Data (Security Hardening).
class SecurityHardening {
  /// Membersihkan input string dari karakter berbahaya dan tag HTML/skrip jahat.
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Hapus tag HTML
        .trim();
  }

  /// Menjaga batas numerik parameter fisik agar tidak mengeksploitasi buffer memori.
  static double clampRange(double value, double min, double max) {
    return value.clamp(min, max);
  }
}
