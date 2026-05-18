class Validators {
  /// Required Field Validation
  static String? validateRequired(String? value, {String fieldName = "Field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// Dynamic User ID Validation (Email or Mobile)
  static String? validateUserIdDynamic(String value) {
    value = value.trim();

    if (value.isEmpty) return "User ID is required";

    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
    final isEmail = validateEmail(value) == null;

    if (isNumeric) {
      // Mobile validation
      return validateMobile(value);
    } else if (isEmail) {
      // Email valid
      return null;
    } else {
      // Invalid format
      return "Enter a valid email";
    }
  }

  /// Street Validation (allow letters, numbers, spaces, and some punctuation)
  static String? validateStreet(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Street is required";
    }
    if (!RegExp(r'^[a-zA-Z0-9\s,.-]+$').hasMatch(value)) {
      return "Enter a valid street address";
    }
    return null;
  }

  /// City Validation (letters & spaces only)
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "City is required";
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return "Enter a valid city name";
    }
    return null;
  }

  /// State Validation (letters & spaces only)
  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "State is required";
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return "Enter a valid state name";
    }
    return null;
  }

  /// Pincode Validation (6 digits)
  static String? validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Pincode is required";
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return "Enter a valid 6-digit pincode";
    }
    return null;
  }

  /// Email Validation (Optional)
  static String? validateEmail(String? value) {
    // If value is null or empty, return null (no error)
    // This allows for optional email fields
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    //if value is not null or empty, perform validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address";
    }

    return null; // Valid email
  }

  /// Password Validation (min 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    return null;
  }

  /// Contact Number Validation (10 digits)
  static String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Mobile number is required";
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter a valid 10-digit mobile number";
    }
    return null;
  }

  /// Emergency Contact Number Validation (10 digits)
  static String? validateEmergencyContact(String? value) {
    // If value is null or empty, return null (no error)
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // If value is not null or empty, perform validation
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter a valid 10-digit mobile number";
    }

    return null;
  }
}
