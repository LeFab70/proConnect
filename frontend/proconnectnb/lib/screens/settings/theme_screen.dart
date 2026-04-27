import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/settings_provider.dart';
import '../../widgets/tr_text.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const TrText("theme"),
      ),
      body: SwitchListTile(
        title: const TrText("dark_mode"),
        value: settings.theme == AppTheme.dark,
        onChanged: (_) => settings.toggleTheme(),
      ),
    );
  }
}