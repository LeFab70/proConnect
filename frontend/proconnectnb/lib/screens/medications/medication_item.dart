import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class MedicationItem extends StatelessWidget {
  final String id;
  final String nom;
  final String marque;
  final String dosage;
  final String frequence;
  final String? urlPhoto;
  final bool isActive;

  final Function(bool) onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;

  const MedicationItem({
    super.key,
    required this.id,
    required this.nom,
    required this.marque,
    required this.dosage,
    required this.frequence,
    this.urlPhoto,
    required this.isActive,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const TrText('Supprimer'),
                content: const TrText('Supprimer ce médicament ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const TrText('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const TrText('Supprimer'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? const Color(0xFF0052D4)
                : isActive
                    ? const Color(0xFF7CD4FD)
                    : Colors.grey,
            backgroundImage: !isSelected &&
                    urlPhoto != null &&
                    urlPhoto!.trim().isNotEmpty
                ? NetworkImage(urlPhoto!)
                : null,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : urlPhoto != null && urlPhoto!.trim().isNotEmpty
                    ? null
                    : const Icon(Icons.medication, color: Colors.white),
          ),
          title: TrText(
            marque.trim().isEmpty ? nom : '$nom ($marque)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: isActive ? null : TextDecoration.lineThrough,
            ),
          ),
          subtitle: TrText('Dosage: $dosage • Fréquence: $frequence'),
          trailing: Switch(
            value: isActive,
            onChanged: onToggle,
            activeColor: const Color(0xFF0052D4),
          ),
        ),
      ),
    );
  }
}