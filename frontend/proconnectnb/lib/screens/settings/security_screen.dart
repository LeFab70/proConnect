import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sécurité")),
      body: Column(
        children: [
          ListTile(
            title: const TrText("Changer mot de passe"),
            onTap: () {},
          ),
          ListTile(
            title: const TrText("Supprimer compte"),
            textColor: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}