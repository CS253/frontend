/// Utility function to get initials from a full name.
/// Example: "John Doe" -> "JD"
String getInitials(String name) {
  if (name.trim().isEmpty) return '??';
  
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();

  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  
  if (parts.isNotEmpty) {
    final first = parts.first;
    if (first.length >= 2) {
      return first.substring(0, 2).toUpperCase();
    }
    return first.toUpperCase();
  }
  
  return '??';
}

