class PrinterLang {
  final String langCode;

  PrinterLang(this.langCode);

  static final Map<String, Map<String, String>> _messages = {
    'en': {
      'queue_number': 'Queue Number',
      'scan_instruction': 'Scan the QR Code below to update your queue',
      'cancel_instruction': 'To cancel your queue, use the code below',
      'printed_at': 'Printed at',
      'start_shift': 'Start Shift',
      'end_shift_at': 'End Shift At',
      'queue': 'Queue',
      'note': 'Note: Show this paper to our greeter.',
      'note_cancel': 'If you miss your turn after :callCount',
      'plural_call': 'calls',
      'singular_call': 'call',
      'take_a_number': "you'll need to take a new number.",
    },
    'id': {
      'queue_number': 'Nomor Antrean',
      'scan_instruction': 'Pindai kode QR untuk melihat status antrean',
      'cancel_instruction': 'Untuk batalkan antrean, gunakan kode berikut',
      'printed_at': 'Tanggal cetak',
      'start_shift': 'Mulai Shift',
      'end_shift_at': 'Selesai Shift Pada',
      'queue': 'Antrean',
      'plural_call': 'kali',
      'singular_call': 'kali',
      'note': 'Catatan: Tunjukkan kertas ini ke greeter.',
      'note_cancel': 'Jika Anda melewatkan panggilan setelah :callCount',
      'take_a_number': "Anda perlu mengambil nomor antrean baru",
    },
  };

  /// Get a translated message for a given key and replace placeholders with dynamic values
  String customMessage(String key, {Map<String, String>? placeholders}) {
    String message = _messages[langCode]?[key] ?? _messages['en']?[key] ?? key;

    // Replace placeholders in the message
    if (placeholders != null) {
      placeholders.forEach((placeholder, value) {
        message = message.replaceAll(':$placeholder', value);
      });
    }
    return message;
  }

  /// Add or update a message in a specific language
  static void addOrUpdateMessage(String langCode, String key, String value) {
    if (_messages[langCode] == null) {
      _messages[langCode] = {};
    }
    _messages[langCode]![key] = value;
  }

  /// Add a new language with its messages
  static void addLanguage(String langCode, Map<String, String> messages) {
    _messages[langCode] = messages;
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String langCode) {
    return _messages.containsKey(langCode);
  }
}
