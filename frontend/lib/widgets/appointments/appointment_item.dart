import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentItem extends StatelessWidget {
  final String docteur;
  final String lieu;
  final DateTime dateHeure;
  final String? notes;

  const AppointmentItem({
    super.key,
    required this.docteur,
    required this.lieu,
    required this.dateHeure,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF7CD4FD),
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        title: Text("Dr. $docteur", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 $lieu"),
            Text("🕒 ${DateFormat('dd/MM/yyyy - HH:mm').format(dateHeure)}"),
            if (notes != null && notes!.isNotEmpty)
              Text("📝 $notes", style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        isThreeLine: notes != null && notes!.isNotEmpty,
      ),
    );
  }
}