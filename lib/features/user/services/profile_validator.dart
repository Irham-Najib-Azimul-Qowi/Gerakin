/// Validasi utilitas untuk masukan data profil pengguna.
class ProfileValidator {
  /// Validasi nama tampilan agar tidak kosong.
  static bool validateDisplayName(String name) {
    return name.trim().isNotEmpty;
  }

  /// Validasi tinggi badan masuk akal (dalam sentimeter).
  static bool validateHeight(double height) {
    return height >= 50.0 && height <= 250.0;
  }

  /// Validasi berat badan masuk akal (dalam kilogram).
  static bool validateWeight(double weight) {
    return weight >= 10.0 && weight <= 300.0;
  }

  /// Validasi tanggal lahir (usia realistis: 0 s.d 120 tahun).
  static bool validateBirthDate(DateTime date) {
    if (date.isAfter(DateTime.now())) return false;
    final age = DateTime.now().difference(date).inDays / 365.25;
    return age >= 0 && age <= 120;
  }
}
