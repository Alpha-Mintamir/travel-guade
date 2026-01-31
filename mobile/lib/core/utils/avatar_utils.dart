/// DiceBear Avatar Utilities
/// Generates avatar URLs using the free DiceBear API
/// https://www.dicebear.com/

class AvatarUtils {
  AvatarUtils._();

  /// Available DiceBear avatar styles
  /// These styles generate diverse avatars including masculine and feminine looks
  static const List<AvatarStyle> styles = [
    AvatarStyle('adventurer', 'Adventurer', '🧑‍🎤'),
    AvatarStyle('adventurer-neutral', 'Neutral', '🧑'),
    AvatarStyle('avataaars', 'Avataaars', '😎'),
    AvatarStyle('lorelei', 'Lorelei', '✨'),
    AvatarStyle('lorelei-neutral', 'Elegant', '💫'),
    AvatarStyle('micah', 'Micah', '🎨'),
    AvatarStyle('notionists', 'Notionists', '📝'),
    AvatarStyle('notionists-neutral', 'Minimal', '📋'),
    AvatarStyle('personas', 'Personas', '👤'),
    AvatarStyle('big-ears', 'Big Ears', '🐰'),
    AvatarStyle('big-ears-neutral', 'Cute', '🎀'),
    AvatarStyle('open-peeps', 'Open Peeps', '👩'),
    AvatarStyle('bottts', 'Robots', '🤖'),
    AvatarStyle('pixel-art', 'Pixel Art', '👾'),
    AvatarStyle('fun-emoji', 'Fun Emoji', '😄'),
  ];

  /// Generate a DiceBear avatar URL
  static String generateAvatarUrl({
    required String seed,
    required String style,
    int size = 200,
  }) {
    final encodedSeed = Uri.encodeComponent(seed);
    return 'https://api.dicebear.com/8.x/$style/png?seed=$encodedSeed&size=$size';
  }

  /// Generate a random seed for avatar
  static String generateRandomSeed() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get all avatar options for a given seed
  static List<AvatarOption> getAllAvatarOptions(String seed, {int size = 200}) {
    return styles.map((style) => AvatarOption(
      style: style,
      url: generateAvatarUrl(seed: seed, style: style.id, size: size),
    )).toList();
  }

  /// Extract style from a DiceBear URL (if possible)
  static String? extractStyleFromUrl(String url) {
    // URL format: https://api.dicebear.com/8.x/{style}/png?...
    final regex = RegExp(r'dicebear\.com/\d+\.x/([^/]+)/');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Extract seed from a DiceBear URL (if possible)
  static String? extractSeedFromUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri?.queryParameters['seed'];
  }
}

/// Represents a DiceBear avatar style
class AvatarStyle {
  final String id;
  final String name;
  final String emoji;

  const AvatarStyle(this.id, this.name, this.emoji);
}

/// Represents an avatar option with style and URL
class AvatarOption {
  final AvatarStyle style;
  final String url;

  const AvatarOption({required this.style, required this.url});
}
