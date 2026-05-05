import 'package:flutter/material.dart';
import '../../widgets/global/custom_button.dart';
import '../../widgets/global/custom_input.dart';

class AddMedicationForm extends StatefulWidget {
  // Le callback inclut maintenant l'heure (5 paramètres au total)
  final Function(String nom, String marque, String dosage, String frequence, String heure) onSubmit;

  const AddMedicationForm({super.key, required this.onSubmit});

  @override
  State<AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final _nomController = TextEditingController();
  final _marqueController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequenceController = TextEditingController();
  
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    // Toujours libérer les contrôleurs pour éviter les fuites de mémoire
    _nomController.dispose();
    _marqueController.dispose();
    _dosageController.dispose();
    _frequenceController.dispose();
    super.dispose();
  }

  // Fonction pour ouvrir le sélecteur d'heure
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0052D4), // Bleu ProConnectNB
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    // Validation simple
    if (_nomController.text.isEmpty || _dosageController.text.isEmpty || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Nom, dosage et heure requis"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Formatage de l'heure en String (HH:mm)
    final String formattedTime =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    // Envoi des données au parent
    widget.onSubmit(
      _nomController.text.trim(),
      _marqueController.text.trim(),
      _dosageController.text.trim(),
      _frequenceController.text.trim(),
      formattedTime,
    );

    // Réinitialisation du formulaire
    _nomController.clear();
    _marqueController.clear();
    _dosageController.clear();
    _frequenceController.clear();
    setState(() => _selectedTime = null);
    
    // Fermer le clavier
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ajout rapide",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF0F172A)
            ),
          ),
          const SizedBox(height: 16),
          
          CustomInput(
            controller: _nomController, 
            label: "Nom du médicament", 
            icon: Icons.medication_rounded
          ),
          const SizedBox(height: 12),
          
          CustomInput(
            controller: _marqueController, 
            label: "Marque (ex: Sanofi)", 
            icon: Icons.branding_watermark_outlined
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomInput(
                  controller: _dosageController, 
                  label: "Dosage", 
                  icon: Icons.monitor_weight_outlined
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: _buildTimePickerField(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          CustomInput(
            controller: _frequenceController, 
            label: "Fréquence (ex: 2/jour)", 
            icon: Icons.repeat_rounded
          ),
          const SizedBox(height: 20),
          
          CustomButton(
            text: "Ajouter au traitement", 
            onPressed: _submit
          ),
        ],
      ),
    );
  }

  // Widget personnalisé pour l'affichage de l'heure choisie
  Widget _buildTimePickerField() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        height: 60, // S'aligner sur la hauteur de CustomInput
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time_rounded, color: Colors.grey[600], size: 20),
            const SizedBox(width: 6),
            Text(
              _selectedTime != null
                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                  : "Heure",
              style: TextStyle(
                color: _selectedTime != null ? const Color(0xFF0F172A) : Colors.grey[600],
                fontWeight: _selectedTime != null ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}