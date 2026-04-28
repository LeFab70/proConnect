import 'package:flutter/material.dart';
import '../../models/rappel.dart';
import '../../widgets/rappels/rappel_item.dart';
import '../../widgets/rappels/add_rappel_form.dart';
import '../../widgets/tr_text.dart';

class RappelScreen extends StatefulWidget {
  const RappelScreen({super.key});

  @override
  State<RappelScreen> createState() => _RappelScreenState();
}

class _RappelScreenState extends State<RappelScreen> {
  final List<Rappel> _rappels = [];

  void _addRappel(String type, DateTime date, bool isMed) {
    setState(() {
      _rappels.add(Rappel(
        id: DateTime.now().millisecondsSinceEpoch,
        type: type,
        dateHeure: date,
        actif: true,
        medicamentId: isMed ? 1 : null,
        rendezVousMedicalId: isMed ? null : 1,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("Mes Rappels"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AddRappelForm(onSubmit: _addRappel),
            const SizedBox(height: 25),
            _rappels.isEmpty
                ? const Text("Aucun rappel actif")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rappels.length,
                    itemBuilder: (ctx, i) {
                      final rappel = _rappels[i];
                      return RappelItem(
                        type: rappel.type,
                        dateHeure: rappel.dateHeure,
                        actif: rappel.actif,
                        isMedicament: rappel.medicamentId != null,
                        onToggle: (val) {
                          // Logique pour activer/désactiver via l'API plus tard
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}