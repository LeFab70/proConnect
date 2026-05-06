import 'package:flutter/material.dart';
import '../global/card_widget.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final IconData icon;
  final VoidCallback onLongPress;

  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.onLongPress, 
    this.icon = Icons.local_activity,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: CardWidget(
        child: Row(
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue),
            ),

            const SizedBox(width: 15),

            // Infos activité
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(description),
                  const SizedBox(height: 5),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}