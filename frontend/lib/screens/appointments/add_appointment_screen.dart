import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/appointments/add_appointment_form.dart';
import '../../models/appointment.dart';
import '../../widgets/tr_text.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  bool _ajouterAuxRappels = true;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: const Color(0xFF000428),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF004E92), Color(0xFF000428)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF004E92).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      child: Column(
                        children: [
                          _buildIntroCard(),
                          const SizedBox(height: 16),
                          _buildRappelToggle(),
                          const SizedBox(height: 16),
                          _buildFormCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const TrText(
            "Nouveau Rendez-vous",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF004E92).withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Color(0xFF7DC4FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TrText(
              "Remplissez les détails du rendez-vous médical.",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRappelToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _ajouterAuxRappels
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ajouterAuxRappels
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _ajouterAuxRappels
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: _ajouterAuxRappels
                ? const Color(0xFF34D399)
                : Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  "Ajouter aux rappels",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                TrText(
                  _ajouterAuxRappels
                      ? "Un rappel sera créé 1h avant"
                      : "Aucun rappel ne sera créé",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _ajouterAuxRappels,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF10B981),
            inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            onChanged: (value) {
              setState(() => _ajouterAuxRappels = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      child: AddAppointmentForm(
        onSubmit: (dateHeure, lieu, docteur, notes) async {
          final rdv = RendezVousMedical(
            id: DateTime.now().microsecondsSinceEpoch,
            dateHeure: dateHeure,
            lieu: lieu,
            docteur: docteur,
            notes: notes ?? '',
            aineId: 1,
          );

          if (!mounted) return;

          Navigator.pop(context, {
            'appointment': rdv,
            'addToReminder': _ajouterAuxRappels,
          });
        },
      ),
    );
  }
}
