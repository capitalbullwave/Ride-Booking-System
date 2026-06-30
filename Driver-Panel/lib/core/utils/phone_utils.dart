class PhoneUtils {
  PhoneUtils._();

  /// Combines dial code and local number into E.164 format expected by the backend.
  static String normalize(String phone, String countryCode) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final code = countryCode.startsWith('+')
        ? countryCode
        : '+$countryCode';

    if (digits.length == 10) {
      return '$code$digits';
    }
    if (digits.startsWith('91') && digits.length == 12) {
      return '+$digits';
    }
    if (phone.startsWith('+')) {
      return phone.replaceAll(RegExp(r'[^\d+]'), '');
    }
    return '$code$digits';
  }
}
