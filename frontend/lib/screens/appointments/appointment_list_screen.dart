import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';
import 'add_appointment_screen.dart';
import 'edit_appointment_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final provider = context.read<AppointmentProvider>();

      if (provider.appointments.isEmpty) {
        await provider.fetchAppointments(auth);
      }
    });
  }

  Future<void> _goToAddScreen() async {
    final appointmentProvider = context.read<AppointmentProvider>();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
    );

    if (!mounted) return;

    if (result != null && result is Map<String, dynamic>) {
      final rdv = result['appointment'];

      if (rdv is RendezVousMedical) {
        // Le RDV est déjà dans le provider après POST ; on réaligne au cas où.
        await appointmentProvider.addLocalAppointment(rdv);
        // Rappel lié au RDV : créé sur l'API depuis AddAppointmentScreen (addRappel).
      }
    }
  }

  Future<void> _goToEditScreen(RendezVousMedical rdv) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAppointmentScreen(appointment: rdv),
      ),
    );

    if (!mounted) return;

    if (result != null && result is RendezVousMedical) {
      await context.read<AppointmentProvider>().updateLocalAppointment(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    final appointmentProvider = context.watch<AppointmentProvider>();

    final appointments = appointmentProvider.appointments;

    final upcoming = appointmentProvider.upcomingAppointments;

    final past = appointmentProvider.pastAppointments;

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, appointments, upcoming),

                  Expanded(
                    child: appointments.isEmpty
                        ? _buildEmptyState()
                        : _buildList(upcoming, past),
                  ),
                ],
              ),
            ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToAddScreen,
        backgroundColor: Colors.white,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: Color(0xFF004E92)),
        label: const TrText(
          "Nouveau rendez-vous",
          style: TextStyle(
            color: Color(0xFF004E92),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<RendezVousMedical> appointments,
    List<RendezVousMedical> upcoming,
  ) {
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
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            children: [
              const TrText(
                "Mes Rendez-vous",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),

              if (appointments.isNotEmpty)
                Text(
                  "${upcoming.length} à venir",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "Aucun rendez-vous prévu",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildList(
    List<RendezVousMedical> upcoming,
    List<RendezVousMedical> past,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        if (upcoming.isNotEmpty) ...[
          _buildSectionLabel(
            "À venir",
            Icons.upcoming_rounded,
            const Color(0xFF7DC4FF),
          ),

          const SizedBox(height: 10),

          ...upcoming.map((rdv) => _buildAppointmentCard(rdv, true)),
        ],

        if (past.isNotEmpty) ...[
          const SizedBox(height: 8),

          _buildSectionLabel(
            "Passés",
            Icons.history_rounded,
            Colors.white.withValues(alpha: 0.3),
          ),

          const SizedBox(height: 10),

          ...past.map((rdv) => _buildAppointmentCard(rdv, false)),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),

        const SizedBox(width: 7),

        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(RendezVousMedical rdv, bool upcoming) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr').format(rdv.dateHeure);
    final timeStr = DateFormat('HH:mm').format(rdv.dateHeure);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _goToEditScreen(rdv),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: upcoming
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: upcoming
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.06),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF004E92).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.event_note_rounded,
                color: Color(0xFF7DC4FF),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rdv.docteur.isNotEmpty
                        ? "Dr ${rdv.docteur}"
                        : "Rendez-vous médical",
                    style: TextStyle(
                      color: upcoming
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          dateStr,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (rdv.lieu.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            rdv.lieu,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (rdv.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      rdv.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.edit_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: upcoming ? 0.35 : 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
