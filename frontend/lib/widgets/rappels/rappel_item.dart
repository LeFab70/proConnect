import 'package:flutter/material.dart';

class RappelItem extends StatelessWidget {
  final String type;
  final DateTime dateHeure;
  final bool actif;
  final bool isMedicament;
  final Function(bool) onToggle;

  const RappelItem({
    super.key,
    required this.type,
    required this.dateHeure,
    required this.actif,
    required this.isMedicament,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMedicament ? const Color(0xFF6C5DD3) : const Color(0xFF3F8CFF),
          child: Icon(
            isMedicament ? Icons.medication : Icons.calendar_today,
            color: Colors.white,
          ),
        ),
        title: Text(
          type,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${dateHeure.day}/${dateHeure.month} à ${dateHeure.hour}:${dateHeure.minute.toString().padLeft(2, '0')}",
        ),
        trailing: Switch(
          value: actif,
          activeThumbColor: const Color(0xFF4A3AFF),
          onChanged: onToggle,
        ),
      ),
    );
  }
}