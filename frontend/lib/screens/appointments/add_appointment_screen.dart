import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/appointments/add_appointment_form.dart';
import '../../widgets/tr_text.dart';
import '../../services/local_alarm_service.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/aine_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../models/rappel.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  bool _ajouterAuxRappels = true;
  int? _selectedAineId;

  String _formatHeureRappel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final aines = context.read<AineProvider>();
      if (auth.isAidant && aines.aines.isEmpty) {
        await aines.fetchAines(auth);
      }
      if (!mounted) return;
      if (auth.isAidant) {
        _selectedAineId = aines.selectedAine?.id;
      }
      setState(() {});
    });
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
                      ? "Une alarme locale sera déclenchée à l'heure du rendez-vous"
                      : "Aucune alarme ne sera créée",
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
      child: Consumer2<AuthProvider, AineProvider>(
        builder: (context, auth, aines, _) {
          final availableAines = aines.aines;
          final isAidant = auth.isAidant;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isAidant) ...[
                Text(
                  "Aîné concerné",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedAineId,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF0B1A4A),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  items: availableAines
                      .map(
                        (a) => DropdownMenuItem<int>(
                          value: a.id,
                          child: Text(
                            "${a.prenom} ${a.nom}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selectedAineId = v);
                    final found = availableAines
                        .where((a) => a.id == v)
                        .toList();
                    if (found.isNotEmpty) {
                      // best-effort, avoid async gap warnings in UI handler
                      aines.selectAine(found.first);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              AddAppointmentForm(
                onSubmit: (dateHeure, lieu, docteur, notes) async {
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final provider = context.read<AppointmentProvider>();
                  final rappelProvider = context.read<RappelProvider>();

                  final aineId = auth.isAine
                      ? (auth.currentUserLocalId ?? 0)
                      : (_selectedAineId ?? 0);

          if (aineId <= 0) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Veuillez sélectionner un aîné."),
              ),
            );
            return;
          }

          final data = <String, dynamic>{
            // Send UTC so backend (timestamptz) receives a timezone-aware value.
            "dateHeure": dateHeure.toUtc().toIso8601String(),
            "lieu": lieu,
            "docteur": docteur,
            "notes": notes,
            "aineId": aineId,
          };

          final created = await provider.addAppointment(data, auth);
          if (created == null) {
            if (!mounted) return;
            messenger.showSnackBar(
              SnackBar(
                content: Text(provider.error.isNotEmpty
                    ? provider.error
                    : "Échec de création du rendez-vous"),
              ),
            );
            return;
          }
          final rdv = created;

          if (_ajouterAuxRappels) {
            final rappel = Rappel(
              id: 0,
              dateDebut: DateTime(
                rdv.dateHeure.year,
                rdv.dateHeure.month,
                rdv.dateHeure.day,
              ),
              heureDebut: _formatHeureRappel(rdv.dateHeure),
              minutesAvantRappel: 60,
              dateHeurePrise: rdv.dateHeure,
              dateHeureNotification: rdv.dateHeure.subtract(
                const Duration(minutes: 60),
              ),
              type: 'RendezVousMedical',
              actif: true,
              rendezVousMedicalId: rdv.id,
              groupeId: 'rdv_${rdv.id}',
            );
            final savedReminder = await rappelProvider.addRappel(rappel, auth);
            if (!savedReminder && mounted) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Rendez-vous enregistré, mais le rappel n’a pas pu être enregistré sur le serveur.',
                  ),
                ),
              );
            }
            await LocalAlarmService.scheduleAlarm(
              id: rdv.id,
              title: 'Rendez-vous médical',
              body: 'Rendez-vous avec Dr $docteur à $lieu',
              dateTime: rdv.dateHeure,
            );
          }

          if (!mounted) return;

          navigator.pop({
            'appointment': rdv,
            'addToReminder': _ajouterAuxRappels,
          });
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
