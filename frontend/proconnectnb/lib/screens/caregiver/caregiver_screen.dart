import 'package:flutter/material.dart';
import '../../widgets/global/custom_input.dart';
import '../../widgets/global/custom_button.dart';
import '../../widgets/tr_text.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  // Initialisation des contrôleurs avec les champs du DTO
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _docteurController = TextEditingController();
  final _telDocteurController = TextEditingController();

  bool _isEditing = false;

  void _saveProfile() {
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom et le prénom sont obligatoires")),
      );
      return;
    }
    
    // Logique de sauvegarde API ici
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil mis à jour avec succès")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const TrText("Mon Proche Aidant"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header avec Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF4A3AFF),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),

            // Formulaire basé sur le DTO
            CustomInput(
              controller: _prenomController,
              label: "Prénom",
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 15),
            
            CustomInput(
              controller: _nomController,
              label: "Nom",
              icon: Icons.person,
            ),
            const SizedBox(height: 15),

            CustomInput(
              controller: _telController,
              label: "Téléphone",
              icon: Icons.phone,
            ),
            const SizedBox(height: 15),

            CustomInput(
              controller: _emailController,
              label: "Email",
              icon: Icons.email,
            ),
            const SizedBox(height: 15),

            CustomInput(
              controller: _adresseController,
              label: "Adresse",
              icon: Icons.location_on,
            ),
            const SizedBox(height: 15),

            // Champs supplémentaires du DTO
            CustomInput(
              controller: _docteurController,
              label: "Docteur",
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 15),

            CustomInput(
              controller: _telDocteurController,
              label: "Téléphone du Docteur",
              icon: Icons.local_hospital,
            ),
            
            const SizedBox(height: 30),

            if (_isEditing)
              CustomButton(
                text: "Enregistrer les modifications",
                onPressed: _saveProfile,
              ),
          ],
        ),
      ),
    );
  }
}