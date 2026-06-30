class Validators {
  Validators._();

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? otp(String? value, {int length = 6}) {
    if (value == null || value.length != length) {
      return 'Enter a valid $length-digit OTP';
    }
    return null;
  }

  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pin code is required';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pin code';
    }
    return null;
  }

  static String? ifsc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid IFSC code';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    if (value.replaceAll(RegExp(r'\D'), '').length < 9) {
      return 'Enter a valid account number';
    }
    return null;
  }

  static String? vehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle number is required';
    }
    return null;
  }

  static String? licenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'License number is required';
    }
    return null;
  }
}
