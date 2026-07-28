/// Tingkat prioritas feedback (Priority Level).
///
/// Digunakan oleh [FeedbackPriorityEngine] untuk menyaring pesan mana
/// yang harus mengabaikan/mengalahkan pesan lainnya.
enum FeedbackPriority implements Comparable<FeedbackPriority> {
  low(10),
  medium(20),
  high(30),
  critical(40);

  const FeedbackPriority(this.value);

  final int value;

  @override
  int compareTo(FeedbackPriority other) => value.compareTo(other.value);

  bool operator >(FeedbackPriority other) => value > other.value;
  bool operator >=(FeedbackPriority other) => value >= other.value;
  bool operator <(FeedbackPriority other) => value < other.value;
  bool operator <=(FeedbackPriority other) => value <= other.value;
}
