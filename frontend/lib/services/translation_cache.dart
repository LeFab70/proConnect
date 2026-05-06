class TranslationCache {
  static final Map<String, String> _cache = {};

  static String key(String text, String lang) => "$text-$lang";

  static String? get(String text, String lang) {
    return _cache[key(text, lang)];
  }

  static void set(String text, String lang, String value) {
    _cache[key(text, lang)] = value;
  }
}