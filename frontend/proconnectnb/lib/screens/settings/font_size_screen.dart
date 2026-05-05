import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/settings_provider.dart';
import '../../widgets/tr_text.dart';

class FontSizeScreen extends StatelessWidget {
  const FontSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const TrText("font_size")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Slider(
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: settings.fontSize.toStringAsFixed(1),
              value: settings.fontSize,
              onChanged: settings.setFontSize,
            ),

            const SizedBox(height: 20),
            TrText(
              "preview",
              style: TextStyle(
                fontSize: 18 * settings.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
