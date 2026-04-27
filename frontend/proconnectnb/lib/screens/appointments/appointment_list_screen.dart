import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import '../../widgets/appointments/appointment_item.dart';
import 'add_appointment_screen.dart';
import '../../widgets/tr_text.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  // Liste locale simulée (à remplacer par ton API plus tard)
  final List<RendezVousMedical> _appointments = [];

  void _goToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAppointmentScreen()),
    );

    if (result != null && result is RendezVousMedical) {
      setState(() {
        _appointments.add(result);
        // Optionnel : Trier par date après l'ajout
        _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TrText("Mes Rendez-vous"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const TrText("Aucun rendez-vous prévu", 
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _appointments.length,
              itemBuilder: (ctx, index) {
                final rdv = _appointments[index];
                return AppointmentItem(
                  docteur: rdv.docteur,
                  lieu: rdv.lieu,
                  dateHeure: rdv.dateHeure,
                  notes: rdv.notes,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddScreen,
        backgroundColor: const Color(0xFF4A3AFF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}