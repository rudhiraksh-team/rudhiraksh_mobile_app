class StringUtils {
  /// Returns only the first name from a full name string
  static String getFirstName(String fullName) {
    if (fullName.trim().isEmpty) return "";
    return fullName.split(" ").first;
  }
}
    