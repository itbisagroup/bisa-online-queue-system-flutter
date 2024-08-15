class IsActive {
  final int? value;
  final String? label;
  final String? icon;
  final String? color;

  IsActive({
    this.value,
    this.label,
    this.icon,
    this.color,
  });

  factory IsActive.fromJson(Map<String, dynamic> json) {
    return IsActive(
      value: json['value'],
      label: json['label'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}
