import 'package:flutter/material.dart';
import '../../widgets/global/custom_input.dart';
import '../../widgets/global/custom_button.dart';

class AddActivityForm extends StatefulWidget {
  final Function(String title, String description, String lieu) onSubmit;

  const AddActivityForm({super.key, required this.onSubmit});

  @override
  State<AddActivityForm> createState() => _AddActivityFormState();
}

class _AddActivityFormState extends State<AddActivityForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _lieuController = TextEditingController();

  void _submitData() {
    final enteredTitle = _titleController.text.trim();
    final enteredDesc = _descController.text.trim();
    final enteredLieu = _lieuController.text.trim();

    if (enteredTitle.isEmpty || enteredDesc.isEmpty || enteredLieu.isEmpty) {
      // Affiche un message d'erreur si un champ manque
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    widget.onSubmit(enteredTitle, enteredDesc, enteredLieu);

    // Reset des champs
    _titleController.clear();
    _descController.clear();
    _lieuController.clear();

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Nouvelle Activité",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF001F3F),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            CustomInput(
              controller: _titleController,
              label:
                  'Titre de l\'activité', // CHANGÉ ICI (label au lieu de hintText)
              icon: Icons.title,
            ),
            const SizedBox(height: 12),

            CustomInput(
              controller: _descController,
              label: 'Description', // CHANGÉ ICI
              icon: Icons.description,
            ),
            const SizedBox(height: 12),

            CustomInput(
              controller: _lieuController,
              label: 'Lieu', // CHANGÉ ICI
              icon: Icons.location_on,
            ),
            const SizedBox(height: 20),

            // Utilisation du CustomButton
            CustomButton(text: 'Ajouter l\'activité', onPressed: _submitData),
          ],
        ),
      ),
    );
  }
}
