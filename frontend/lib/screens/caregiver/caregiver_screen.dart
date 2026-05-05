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
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _docteurController = TextEditingController();
  final _telDocteurController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _docteurController.dispose();
    _telDocteurController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_nomController.text.trim().isEmpty ||
        _prenomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le nom et le prénom sont obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isEditing = false);

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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const TrText("Mon Proche Aidant"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF4A3AFF),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),

            const SizedBox(height: 25),

            _field(_prenomController, "Prénom", Icons.person_outline),
            const SizedBox(height: 15),

            _field(_nomController, "Nom", Icons.person),
            const SizedBox(height: 15),

            _field(_telController, "Téléphone", Icons.phone),
            const SizedBox(height: 15),

            _field(_emailController, "Email", Icons.email),
            const SizedBox(height: 15),

            _field(_adresseController, "Adresse", Icons.location_on),
            const SizedBox(height: 15),

            _field(_docteurController, "Docteur", Icons.medical_services),
            const SizedBox(height: 15),

            _field(
              _telDocteurController,
              "Téléphone du Docteur",
              Icons.local_hospital,
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

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return AbsorbPointer(
      absorbing: !_isEditing,
      child: Opacity(
        opacity: _isEditing ? 1 : 0.75,
        child: CustomInput(controller: controller, label: label, icon: icon),
      ),
    );
  }
}
