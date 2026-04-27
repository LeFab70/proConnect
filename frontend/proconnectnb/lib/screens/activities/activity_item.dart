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

    final locale = settings.languageCode == 'fr' ? 'fr_FR' : 'en_US';

    final formattedDate = DateFormat.yMMMEd(locale)
        .add_Hm()
        .format(date);

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

          leading: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blueAccent,
            child: const Icon(Icons.event, color: Colors.white),
          ),

          title: TrText(
            title,
            isDynamic: true, 
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TrText(
              description,
              isDynamic: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}