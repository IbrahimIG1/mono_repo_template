abstract final class AuthValidators {
  static String? email(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Email is required.';
    }
    final separator = normalized.indexOf('@');
    if (separator <= 0 || separator == normalized.length - 1) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value, {int minimumLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < minimumLength) {
      return 'Password must contain at least $minimumLength characters.';
    }
    return null;
  }
}
