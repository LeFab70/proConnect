import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/settings_provider.dart';
import '../services/app_localizations.dart';
import '../services/translation_service.dart';
import '../services/translation_cache.dart';

class TrText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isDynamic;
  final int? maxLines;
  final TextOverflow? overflow;

  const TrText(
    this.text, {
    super.key,
    this.style,
    this.isDynamic = false,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().languageCode;

    // 🔥 TEXTE LOCAL (rapide)
    if (!isDynamic) {
      return Text(
        AppLocalizations.tr(text),
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // 🔥 OPTIMISATION : pas besoin d'API si FR
    if (lang == "fr") {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    // 🔥 TEXTE DYNAMIQUE AVEC CACHE + API
    return FutureBuilder<String>(
      future: _translate(text, lang),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            text, // fallback immédiat
            style: style,
            maxLines: maxLines,
            overflow: overflow,
          );
        }

        return Text(
          snapshot.data ?? text,
          style: style,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  Future<String> _translate(String text, String lang) async {
    final cached = TranslationCache.get(text, lang);
    if (cached != null) return cached;

    try {
      final translated = await TranslationService.translate(text, lang: lang);

      TranslationCache.set(text, lang, translated);
      return translated;
    } catch (e) {
      debugPrint("Erreur traduction: $e");
      return text;
    }
  }
}
