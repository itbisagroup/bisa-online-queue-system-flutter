enum QueueStatus {
  waiting(1, 'Menunggu'),
  calling(2, 'Memanggil'),
  completed(3, 'Selesai'),
  none(4, 'Kosong');  // Changed from "annoying" to more appropriate "Dilewati"

  final int value;
  final String description;
  const QueueStatus(this.value, this.description);

  static QueueStatus fromValue(int value) {
    return values.firstWhere((e) => e.value == value, orElse: () => QueueStatus.waiting);
  }
}