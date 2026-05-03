import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../widgets/tr_text.dart';
import '../../provider/settings_provider.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime date;
  final VoidCallback onLongPress;

  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    final locale = settings.languageCode == 'fr' ? 'fr_FR' : 'en_US';

    final formattedDate = DateFormat.yMMMEd(locale).add_Hm().format(date);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: theme.cardColor,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),

          // =========================
          // ICONE
          // =========================
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
            child: Icon(Icons.event, color: theme.colorScheme.primary),
          ),

          // =========================
          // TITRE
          // =========================
          title: TrText(
            title,
            isDynamic: true,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15 * settings.fontSize,
              color: theme.textTheme.titleMedium?.color,
            ),
          ),

          // =========================
          // DESCRIPTION
          // =========================
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TrText(
              description,
              isDynamic: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13 * settings.fontSize,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),

          // =========================
          // DATE
          // =========================
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 14, color: theme.hintColor),
              const SizedBox(height: 4),
              SizedBox(
                width: 70,
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    color: theme.hintColor,
                    fontSize: 11 * settings.fontSize,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
