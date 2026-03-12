/// Form field validators.
class Validators {
  Validators._();

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
}
