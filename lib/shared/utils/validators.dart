/// Reusable form validation functions.
///
/// Each returns null if valid, or an error message string if invalid.
/// Used with TextFormField's `validator` parameter.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]',
  );

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'Must contain: 1 lowercase, 1 uppercase, 1 number, and 1 special character (@\$!%*?&).';
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required.';
    }
    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'Invalid date format.';
    }
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Date of birth cannot be in the future.';
    }
    final age = now.year - date.year -
        ((now.month < date.month ||
                (now.month == date.month && now.day < date.day))
            ? 1
            : 0);
    if (age < 16) {
      return 'You must be at least 16 years old to register.';
    }
    if (age > 120) {
      return 'Invalid date of birth.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required.';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters.';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String fieldName = 'This field']) {
    if (value == null || value.trim().length < min) {
      return '$fieldName must be at least $min characters.';
    }
    return null;
  }
}
