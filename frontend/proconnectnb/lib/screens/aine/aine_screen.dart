import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class AineScreen extends StatelessWidget {
  const AineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("Gestion des Aînés"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _card(
              context,
              icon: Icons.list,
              title: "Voir les Aînés",
              route: '/listAine',
            ),
            const SizedBox(height: 20),
            _card(
              context,
              icon: Icons.person_add,
              title: "Ajouter un Aîné",
              route: '/addAine',
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(BuildContext context,
      {required IconData icon, required String title, required String route}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 20),
            TrText(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}