enum ThresholdError {
  info,
  notice,
  warning,
  emergency,
  critical,
}

extension ThresholdExtension on ThresholdError {
  String get label {
    switch (this) {
      case ThresholdError.info:
        return 'info';
      case ThresholdError.notice:
        return 'notice';
      case ThresholdError.warning:
        return 'warning';
      case ThresholdError.emergency:
        return 'emergency';
      case ThresholdError.critical:
        return 'critical';
      default:
        return '';
    }
  }
}
