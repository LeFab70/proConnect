import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/rappel.dart';
import '../../provider/auth_provider.dart';
import '../../provider/rappel_provider.dart';
import 'add_appointment_screen.dart';
import '../../widgets/tr_text.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final List<RendezVousMedical> _appointments = [];

  Future<void> _goToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
    );

    if (result != null && result is RendezVousMedical) {
      final rdv = result;

      setState(() {
        _appointments.add(rdv);
        _appointments.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
      });

      final heure =
          '${rdv.dateHeure.hour.toString().padLeft(2, '0')}:${rdv.dateHeure.minute.toString().padLeft(2, '0')}:00';

      final rappel = Rappel(
        id: DateTime.now().microsecondsSinceEpoch,
        dateDebut: rdv.dateHeure,
        heureDebut: heure,
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

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await context.read<RappelProvider>().addRappel(rappel, auth);
    }
  }

  List<RendezVousMedical> get _upcoming {
    final list = _appointments
        .where((r) => r.dateHeure.isAfter(DateTime.now()))
        .toList();
    list.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
    return list;
  }

  List<RendezVousMedical> get _past {
    final list = _appointments
        .where((r) => !r.dateHeure.isAfter(DateTime.now()))
        .toList();
    list.sort((a, b) => b.dateHeure.compareTo(a.dateHeure));
    return list;
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
              top: -80,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF004E92).withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Orb bas-gauche
            Positioned(
              bottom: 100,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
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
                    child: _appointments.isEmpty
                        ? _buildEmptyState()
                        : _buildList(),
                  ),
                ],
              ),
            ),
          ],
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
              if (_appointments.isNotEmpty)
                Text(
                  "${_upcoming.length} à venir",
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

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.event_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucun rendez-vous prévu",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Ajoutez votre premier rendez-vous",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── LIST ──────────────────────────────────────────────────────────────────

  Widget _buildList() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        if (_upcoming.isNotEmpty) ...[
          _buildSectionLabel(
            "À venir",
            Icons.upcoming_rounded,
            const Color(0xFF7DC4FF),
          ),
          const SizedBox(height: 10),
          ..._upcoming.map((rdv) => _buildAppointmentCard(rdv, true)),
        ],
        if (_past.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionLabel(
            "Passés",
            Icons.history_rounded,
            Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          ..._past.map((rdv) => _buildAppointmentCard(rdv, false)),
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

  // ─── CARD ──────────────────────────────────────────────────────────────────

  Widget _buildAppointmentCard(RendezVousMedical rdv, bool upcoming) {
    final timeStr = DateFormat('HH:mm').format(rdv.dateHeure);

    return Container(
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
        boxShadow: upcoming
            ? [
                BoxShadow(
                  color: const Color(0xFF000428).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Bloc date
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: upcoming
                  ? const Color(0xFF004E92).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: upcoming
                    ? const Color(0xFF4A9FE8).withValues(alpha: 0.35)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('d').format(rdv.dateHeure),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: upcoming
                        ? const Color(0xFF7DC4FF)
                        : Colors.white.withValues(alpha: 0.25),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM', 'fr').format(rdv.dateHeure).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: upcoming
                        ? const Color(0xFF7DC4FF).withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rdv.docteur,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: upcoming
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.35),
                    decoration: upcoming ? null : TextDecoration.lineThrough,
                    decorationColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: upcoming ? 0.45 : 0.2),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: upcoming ? 0.6 : 0.25),
                      ),
                    ),
                   if (rdv.lieu.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Colors.white.withValues(alpha: upcoming ? 0.45 : 0.2),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          rdv.lieu,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 
                              upcoming ? 0.55 : 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                if (rdv.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rdv.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: Colors.white.withValues(alpha: upcoming ? 0.3 : 0.12),
          ),
        ],
      ),
    );
  }
}
