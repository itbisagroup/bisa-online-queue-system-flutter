// data/Enum/shift_status.dart
enum ShiftStatus {
  opened(0, 'Dibuka'),
  closed(1, 'Ditutup');

  final int value;
  final String description;

  const ShiftStatus(this.value, this.description);

  static ShiftStatus fromValue(int value) {
    return values.firstWhere((e) => e.value == value);
  }
}