import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/partage_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/tr_text.dart';
import '../../models/partage_suivi.dart';

class DemandesRecuesScreen extends StatelessWidget {
  const DemandesRecuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partageProv = context.watch<PartageProvider>();
    final auth = context.watch<AuthProvider>();

    final currentId = auth.currentUserLocalId ?? 0;
    final currentEmail = auth.email?.toLowerCase().trim();

    final demandes = auth.isAine
        ? <PartageSuivi>[]
        : partageProv.partages.where((p) {
            final emailMatch =
                currentEmail != null &&
                p.procheEmail?.toLowerCase().trim() == currentEmail;

            final idMatch = p.procheAidantId == currentId;

            return (idMatch || emailMatch) &&
                p.statut == StatutPartage.enAttente;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const TrText("Demandes de partage"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: demandes.isEmpty
          ? const Center(child: TrText("Aucune demande en attente"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: demandes.length,
              itemBuilder: (ctx, index) {
                final demande = demandes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person_add),
                          ),
                          title: Text("Relation : ${demande.relation}"),
                          subtitle: const TrText(
                            "Un aîné souhaite partager son suivi avec vous.",
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  partageProv.refuserDemande(demande.id),
                              child: const TrText(
                                "Refuser",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () =>
                                  partageProv.accepterDemande(demande.id, auth),
                              child: const TrText(
                                "Accepter",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
