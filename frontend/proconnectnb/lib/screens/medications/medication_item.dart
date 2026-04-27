import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class MedicationItem extends StatelessWidget {
  final String nom;
  final String marque;
  final String dosage;
  final String frequence;
  final VoidCallback onDelete;

  const MedicationItem({
    super.key,
    required this.nom,
    required this.marque,
    required this.dosage,
    required this.frequence,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF7CD4FD),
          child: Icon(Icons.medication, color: Colors.white),
        ),
        title: TrText("$nom ($marque)", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: TrText("Dosage: $dosage • Frequence: $frequence"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}