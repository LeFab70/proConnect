import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/appointments/add_appointment_form.dart';
import '../../models/appointment.dart';
import '../../models/rappel.dart';
import '../../provider/auth_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../widgets/tr_text.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  bool _ajouterAuxRappels = true;

  String _formatHeure(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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
            // Orb haut-droit
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
                      const Color(0xFF004E92).withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Orb bas-gauche
            Positioned(
              bottom: 80,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.04),
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

  // ─── HEADER ────────────────────────────────────────────────────────────────

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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
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

  // ─── INTRO CARD ────────────────────────────────────────────────────────────

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF004E92).withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A9FE8).withOpacity(0.3),
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
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOGGLE RAPPEL ─────────────────────────────────────────────────────────

  Widget _buildRappelToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _ajouterAuxRappels
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _ajouterAuxRappels
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
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
                : Colors.white.withOpacity(0.3),
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
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                TrText(
                  _ajouterAuxRappels
                      ? "Rappel automatique 1h avant"
                      : "Aucun rappel ne sera créé",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _ajouterAuxRappels,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF10B981),
              inactiveThumbColor: Colors.white.withOpacity(0.3),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              onChanged: (value) => setState(() => _ajouterAuxRappels = value),
            ),
          ),
        ],
      ),
    );
  }

  // ─── FORM CARD ─────────────────────────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: Color(0xFF7DC4FF),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Détails du rendez-vous",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          Divider(color: Colors.white.withOpacity(0.08), height: 24),

          // Formulaire injecté
          AddAppointmentForm(
            onSubmit: (dateHeure, lieu, docteur, notes) async {
              final rdvId = DateTime.now().microsecondsSinceEpoch;

              final nouveauRDV = RendezVousMedical(
                id: rdvId,
                dateHeure: dateHeure,
                lieu: lieu,
                docteur: docteur,
                notes: notes ?? '',
                aineId: 1,
              );

              if (_ajouterAuxRappels) {
                final rappel = Rappel(
                  id: DateTime.now().microsecondsSinceEpoch,
                  dateDebut: dateHeure,
                  heureDebut: _formatHeure(dateHeure),
                  minutesAvantRappel: 60,
                  dateHeurePrise: dateHeure,
                  dateHeureNotification: dateHeure.subtract(
                    const Duration(minutes: 60),
                  ),
                  type: 'RendezVousMedical',
                  actif: true,
                  rendezVousMedicalId: rdvId,
                  groupeId: 'rdv_$rdvId',
                );

                final auth = context.read<AuthProvider>();
                await context.read<RappelProvider>().addRappel(rappel, auth);
              }

              if (context.mounted) {
                Navigator.pop(context, nouveauRDV);
              }
            },
          ),
        ],
      ),
    );
  }
}
