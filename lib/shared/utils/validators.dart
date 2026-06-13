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

  /// Normalizes a user-entered URL: if it lacks a scheme, prepends `https://`.
  ///
  /// The backend validates `website` with `z.string().url()`, which rejects
  /// inputs like `www.minegocio.com` (no protocol). Normalizing here lets users
  /// type the bare domain without the publish failing.
  static String normalizeUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    final hasScheme =
        trimmed.startsWith('http://') || trimmed.startsWith('https://');
    return hasScheme ? trimmed : 'https://$trimmed';
  }

  /// Optional website validator: empty is valid; otherwise it must resolve to a
  /// URL with a dotted host after normalization.
  static String? optionalWebsite(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(normalizeUrl(trimmed));
    if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) {
      return 'Ingresa una URL válida (ej. https://minegocio.com).';
    }
    return null;
  }

  static final _nicknameRegex = RegExp(r'^[a-zA-Z0-9_]+$');

  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nickname is required.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Nickname must be at least 3 characters.';
    }
    if (trimmed.length > 20) {
      return 'Nickname must be at most 20 characters.';
    }
    if (!_nicknameRegex.hasMatch(trimmed)) {
      return 'Only letters, numbers, and underscores allowed.';
    }
    return null;
  }
}
