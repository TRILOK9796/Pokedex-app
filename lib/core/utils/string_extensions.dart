/// Small display helpers for API-provided names.
extension StringDisplay on String {
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleWords =>
      replaceAll('-', ' ').split(' ').map((word) => word.capitalized).join(' ');
}
