import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/rappel.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/auth_provider.dart';
import '../../services/local_alarm_service.dart';
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

      await context.read<AppointmentProvider>().fetchAppointments(auth);
      await context.read<RappelProvider>().fetchRappels(auth);
    });
  }

  Future<void> _goToAddScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
    );

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    await context.read<AppointmentProvider>().fetchAppointments(auth);
    await context.read<RappelProvider>().fetchRappels(auth);
  }

  Future<void> _goToEditScreen(RendezVousMedical rdv) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAppointmentScreen(appointment: rdv),
      ),
    );

    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    await context.read<AppointmentProvider>().fetchAppointments(auth);
    await context.read<RappelProvider>().fetchRappels(auth);

    setState(() {});
  }

  String _formatHeure(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _toggleRendezVousReminder(
    RendezVousMedical rdv,
    bool value,
  ) async {
    final auth = context.read<AuthProvider>();
    final rappelProvider = context.read<RappelProvider>();
    final now = DateTime.now();

    final rappelsLies = rappelProvider.rappels
        .where((r) => r.rendezVousMedicalId == rdv.id)
        .toList();

    if (value) {
      if (rdv.dateHeure.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Impossible d’activer un rendez-vous dont la date est déjà passée.",
            ),
          ),
        );
        return;
      }

      if (rappelsLies.isNotEmpty) {
        for (final rappel in rappelsLies) {
          await rappelProvider.toggleRappel(rappel.id, true, auth);
        }
      } else {
        final rappel = Rappel(
          id: 0,
          dateDebut: DateTime(
            rdv.dateHeure.year,
            rdv.dateHeure.month,
            rdv.dateHeure.day,
          ),
          heureDebut: _formatHeure(rdv.dateHeure),
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

        await rappelProvider.addRappel(rappel, auth);
      }

      try {
        await LocalAlarmService.scheduleAlarm(
          id: rdv.id,
          title: 'Rendez-vous médical',
          body: 'Rendez-vous avec Dr ${rdv.docteur} à ${rdv.lieu}',
          dateTime: rdv.dateHeure,
        );
      } catch (e) {
        debugPrint("Erreur programmation alarme rendez-vous ${rdv.id}: $e");
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rendez-vous ajouté aux rappels.")),
      );
    } else {
      for (final rappel in rappelsLies) {
        await rappelProvider.deleteRappel(rappel.id, auth);
      }

      try {
        await LocalAlarmService.cancelAlarm(rdv.id);
      } catch (e) {
        debugPrint("Erreur annulation alarme rendez-vous ${rdv.id}: $e");
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rendez-vous retiré des rappels.")),
      );
    }

    if (mounted) {
      await rappelProvider.fetchRappels(auth);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le rendez-vous"),
        content: const Text("Voulez-vous vraiment supprimer ce rendez-vous ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Supprimer",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _deleteAppointment(RendezVousMedical rdv) async {
    final auth = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();
    final rappelProvider = context.read<RappelProvider>();

    final rappelsLies = rappelProvider.rappels
        .where((r) => r.rendezVousMedicalId == rdv.id)
        .toList();

    for (final rappel in rappelsLies) {
      await rappelProvider.deleteRappel(rappel.id, auth);
    }

    try {
      await LocalAlarmService.cancelAlarm(rdv.id);
    } catch (e) {
      debugPrint("Erreur annulation alarme rendez-vous ${rdv.id}: $e");
    }

    await appointmentProvider.deleteAppointment(rdv.id, auth);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Rendez-vous supprimé")));
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
          ...upcoming.map((rdv) => _buildDismissibleAppointment(rdv, true)),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionLabel(
            "Passés",
            Icons.history_rounded,
            Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          ...past.map((rdv) => _buildDismissibleAppointment(rdv, false)),
        ],
      ],
    );
  }

  Widget _buildDismissibleAppointment(RendezVousMedical rdv, bool upcoming) {
    return Dismissible(
      key: ValueKey("rdv_${rdv.id}"),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await _confirmDelete(context);
      },
      onDismissed: (_) async {
        await _deleteAppointment(rdv);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 30),
      ),
      child: _buildAppointmentCard(rdv, upcoming),
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

    return Consumer<RappelProvider>(
      builder: (context, rappelProvider, _) {
        final hasActiveReminder = rappelProvider.rappels.any(
          (r) => r.rendezVousMedicalId == rdv.id && r.actif,
        );

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
                    color: hasActiveReminder
                        ? const Color(0xFF10B981).withValues(alpha: 0.25)
                        : const Color(0xFF004E92).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    hasActiveReminder
                        ? Icons.notifications_active_rounded
                        : Icons.event_note_rounded,
                    color: hasActiveReminder
                        ? const Color(0xFF34D399)
                        : const Color(0xFF7DC4FF),
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
                Switch(
                  value: hasActiveReminder,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF10B981),
                  inactiveThumbColor: Colors.white.withValues(alpha: 0.45),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                  onChanged: (value) async {
                    await _toggleRendezVousReminder(rdv, value);
                  },
                ),
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: upcoming ? 0.35 : 0.15),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
