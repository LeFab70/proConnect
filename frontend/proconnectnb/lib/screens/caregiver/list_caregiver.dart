import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/caregiver_provider.dart';
import 'add_caregiver_screen.dart';
import '../../widgets/tr_text.dart';

class ListCaregiverScreen extends StatelessWidget {
  const ListCaregiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CaregiverProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const TrText("Mes Proches Aidants"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: provider.caregivers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 10),
                  const TrText(
                    "Aucun aidant enregistré",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: provider.caregivers.length,
              itemBuilder: (ctx, index) {
                final caregiver = provider.caregivers[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF4A3AFF),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: TrText("${caregiver.prenom} ${caregiver.nom}"),
                    subtitle: TrText(
                      "${caregiver.telephone}\n${caregiver.email}\n${caregiver.relation}",
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeCaregiver(caregiver.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A3AFF),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCaregiverScreen()),
          );
        },
      ),
    );
  }
}