import 'package:flutter/material.dart';
import '../../widgets/appointments/add_appointment_form.dart';
import '../../models/appointment.dart';
import '../../widgets/tr_text.dart';

class AddAppointmentScreen extends StatelessWidget {
  const AddAppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("Nouveau Rendez-vous"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TrText(
              "Remplissez les détails du rendez-vous médical.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            AddAppointmentForm(
              onSubmit: (dateHeure, lieu, docteur, notes) {
               
                final nouveauRDV = RendezVousMedical(
                  id: DateTime.now().millisecondsSinceEpoch,
                  dateHeure: dateHeure,
                  lieu: lieu,
                  docteur: docteur,
                  notes: notes,
                  aineId: 1,
                );

                Navigator.pop(context, nouveauRDV);
              },
            ),
          ],
        ),
      ),
    );
  }
}