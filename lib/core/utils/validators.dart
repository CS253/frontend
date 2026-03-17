// =============================================================================
// Validators — Reusable input validation functions.
//
// Used by auth screens, trip creation forms, and payment forms
// for client-side validation before submitting data to the backend.
// =============================================================================

class Validators {
  // Prevent instantiation
  Validators._();

  // ---------------------------------------------------------------------------
  // General Validators (HEAD branch — Payments)
  // ---------------------------------------------------------------------------

  /// Validate that a value is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate that a value is a positive number.
  static String? positiveNumber(String? value, [String fieldName = 'Amount']) {
    final requiredError = required(value, fieldName);
    if (requiredError != null) return requiredError;

    final number = double.tryParse(value!);
    if (number == null) return '$fieldName must be a valid number';
    if (number <= 0) return '$fieldName must be greater than zero';
    return null;
  }

  /// Validate a UPI ID format.
  static String? upiId(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    if (!value.contains('@')) return 'Enter a valid UPI ID (e.g. name@upi)';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Auth Validators (Sarim branch)
  // ---------------------------------------------------------------------------

  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone number (mandatory exactly 10 digits).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  /// Validates password (min 8 chars, at least one letter and one number).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates that confirm password matches password.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates OTP code.
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Trip Validators (Sarim branch)
  // ---------------------------------------------------------------------------

  /// Validates trip name.
  static String? validateTripName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Trip name is required';
    }
    if (value.trim().length < 2) {
      return 'Trip name must be at least 2 characters';
    }
    return null;
  }

  /// Validates destination.
  static String? validateDestination(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Destination is required';
    }
    return null;
  }

  /// Validates member name.
  static String? validateMemberName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }
}
