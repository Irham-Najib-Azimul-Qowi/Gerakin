/// Layanan moderasi konten otomatis untuk mendeteksi kata-kata kasar / terlarang.
class ContentModerationService {
  static const List<String> _blockedWords = [
    'anjing',
    'babi',
    'monyet',
    'kunyuk',
    'bajingan',
    'bangsat',
    'kontol',
    'memek',
    'ngentot',
    'pantek',
    'puki',
    'goblok',
    'tolol',
    'idiot',
    'bego',
    'kampang',
    'lonte',
    'perek',
    'fuck',
    'shit',
    'bitch',
    'asshole',
  ];

  /// Memeriksa apakah [text] mengandung kata terlarang (case-insensitive).
  /// Mengembalikan `true` jika konten mengandung kata terlarang.
  bool containsProhibitedContent(String text) {
    if (text.trim().isEmpty) return false;
    final lowerText = text.toLowerCase();

    for (final word in _blockedWords) {
      final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (pattern.hasMatch(lowerText) || lowerText.contains(word)) {
        return true;
      }
    }
    return false;
  }
}
