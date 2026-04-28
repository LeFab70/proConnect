import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/settings_provider.dart';
import '../../provider/activity_provider.dart';
import '../../widgets/tr_text.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _changeLanguage(BuildContext context, AppLanguage lang) async {
    final settings = context.read<SettingsProvider>();
    final activityProvider = context.read<ActivityProvider>();

    await settings.setLanguage(lang);

    await activityProvider.fetchAIActivities();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: TrText("language")),
      body: Column(
        children: [
          RadioListTile<AppLanguage>(
            title: const Text("Français"),
            value: AppLanguage.fr,
            groupValue: settings.language,
            onChanged: (val) async {
              if (val == null) return;
              await _changeLanguage(context, val);
              context.read<ActivityProvider>().fetchAIActivities();
            },
          ),

          RadioListTile<AppLanguage>(
            title: const Text("English"),
            value: AppLanguage.en,
            groupValue: settings.language,
            onChanged: (val) async {
              if (val == null) return;
              await _changeLanguage(context, val);
              context.read<ActivityProvider>().fetchAIActivities();
            },
          ),
        ],
      ),
    );
  }
}
