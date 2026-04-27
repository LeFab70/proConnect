import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class AddAineScreen extends StatefulWidget {
  const AddAineScreen({super.key});

  @override
  State<AddAineScreen> createState() => _AddAineScreenState();
}

class _AddAineScreenState extends State<AddAineScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      // 👉 API à brancher ici

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aîné ajouté avec succès")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("Ajouter un Aîné"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom complet"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Âge"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _save,
                child: const TrText("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}