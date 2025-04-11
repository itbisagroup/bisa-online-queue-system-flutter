enum ShiftStatus {
  opened(0, 'Dibuka'),
  closed(1, 'Ditutup');

  final int value;
  final String description;

  const ShiftStatus(this.value, this.description);

  static ShiftStatus fromValue(int value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShiftStatus.opened,
    );
  }

  static List<Map<String, dynamic>> get options => values
      .map((e) => {
            'value': e.value,
            'label': e.description,
          })
      .toList();

  String get label => description;

  @override
  String toString() => 'ShiftStatus.$name';
}
