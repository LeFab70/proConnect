import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class ListAineScreen extends StatelessWidget {
  const ListAineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 FAKE DATA (à remplacer par API)
    final List<Map<String, String>> aines = [
      {"name": "Jean Dupont", "age": "78"},
      {"name": "Marie Tremblay", "age": "82"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const TrText("Liste des Aînés"),
      ),
      body: ListView.builder(
        itemCount: aines.length,
        itemBuilder: (context, index) {
          final aine = aines[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(aine["name"]!),
              subtitle: Text("Âge: ${aine["age"]}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 👉 détails à ajouter plus tard
              },
            ),
          );
        },
      ),
    );
  }
}