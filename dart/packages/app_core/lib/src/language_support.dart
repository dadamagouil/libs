// Which interface languages an app offers, and how to fall back for the others.

/// Name of each language in its own language (what a language picker shows).
const languageNativeNames = <String, String>{
  'fr': 'Français',
  'en': 'English',
  'de': 'Deutsch',
  'it': 'Italiano',
};

class LanguageSupport {
  const LanguageSupport({required this.codes, required this.fallback});

  /// Offered languages, the first one being the one the translations were written in.
  final List<String> codes;

  /// Language used when the device or the stored value is not offered.
  final String fallback;

  /// [code] if offered (case-insensitive), otherwise [fallback].
  String normalize(String? code) {
    final lower = code?.toLowerCase();
    return codes.contains(lower) ? lower! : fallback;
  }
}
