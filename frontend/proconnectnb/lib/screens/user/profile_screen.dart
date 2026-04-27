import 'package:flutter/material.dart';
import '../../widgets/global/custom_input.dart';
import '../../widgets/global/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nomController = TextEditingController(text: "Tremblay");
  final _prenomController = TextEditingController(text: "Lucie");
  final _telController = TextEditingController(text: "506-555-0199");
  final _emailController = TextEditingController(text: "lucie.t@email.com");
  final _roleController = TextEditingController(text: "Caregiver");

  void _updateUser() {
    // Ici on simule la validation du DTO côté Flutter
    if (_nomController.text.isEmpty || _prenomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom et le prénom sont obligatoires")),
      );
      return;
    }

    // Logique d'appel API (PUT /api/users/...)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil mis à jour avec succès"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF4A3AFF),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 30),
            
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
              controller: _roleController,
              label: "Rôle",
              icon: Icons.badge,
            ),
            
            const SizedBox(height: 30),
            CustomButton(
              text: "Enregistrer les modifications",
              onPressed: _updateUser,
            ),
          ],
        ),
      ),
    );
  }
}