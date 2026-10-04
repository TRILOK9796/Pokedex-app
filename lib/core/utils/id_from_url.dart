/// Extracts a Pokémon ID from its canonical PokéAPI resource URL.
int idFromUrl(String url) {
  final segments = Uri.parse(url).pathSegments.where((part) => part.isNotEmpty);
  if (segments.isEmpty) {
    throw FormatException('Pokémon URL does not contain an ID: $url');
  }
  final id = int.tryParse(segments.last);
  if (id == null || id <= 0) {
    throw FormatException('Pokémon URL contains an invalid ID: $url');
  }
  return id;
}
