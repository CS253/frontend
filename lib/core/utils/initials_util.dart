/// Utility function to get initials from a full name.
/// Example: "John Doe" -> "JD"
String getInitials(String name) {
  if (name.isEmpty) return '??';
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    if (parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
  }
  final cleanName = name.trim();
  return cleanName.substring(0, cleanName.length >= 2 ? 2 : 1).toUpperCase();
}
