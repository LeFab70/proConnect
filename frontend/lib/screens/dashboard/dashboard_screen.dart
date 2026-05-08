import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/tr_text.dart';
import 'package:intl/intl.dart';

import '../../provider/auth_provider.dart';
import '../../provider/medication_provider.dart';
import '../../provider/activity_provider.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/aine_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/partage_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fabrice | 2026-05-05T04:56:37Z | Précharge médicaments, rappels, partages, RDV et suggestions IA après connexion.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.token == null) return;

      await Future.wait([
        context.read<MedicationProvider>().fetchMedications(auth),
        context.read<RappelProvider>().fetchRappels(auth),
        context.read<PartageProvider>().fetchPartages(auth),
        context.read<AppointmentProvider>().fetchAppointments(auth),
        context.read<AineProvider>().fetchAines(auth),
        context.read<CaregiverProvider>().fetchCaregivers(auth),
      ]);

      if (!mounted) return;
      await context.read<ActivityProvider>().fetchAIActivities(auth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final partage = context.watch<PartageProvider>();
    final meds = context.watch<MedicationProvider>();
    final activity = context.watch<ActivityProvider>();
    final caregivers = context.watch<CaregiverProvider>();
    final aines = context.watch<AineProvider>();
    final rappelProvider = context.watch<RappelProvider>();

    final bool isProcheSansAine = auth.isAidant && aines.selectedAine == null;

    final nbDemandes = partage.countDemandesPourProche(auth);

    final int aineIdActif =
        aines.selectedAine?.id ?? auth.currentUserLocalId ?? 0;

    final activeMeds = isProcheSansAine
        ? []
        : meds.medications
              .where((m) => m.aineId == aineIdActif)
              .where((m) => m.isActive)
              .where((m) => !m.isDeleted)
              .toList();

    final remainingMeds = isProcheSansAine
        ? 0
        : activeMeds.where((m) => m.status == 'enAttente').length;

    final missedMeds = isProcheSansAine
        ? 0
        : activeMeds.where((m) => m.status == 'nonPris').length;

    final activeReminders = isProcheSansAine
        ? 0
        : rappelProvider.rappelsDuJour.length;

    final relationCount = auth.isAine
        ? caregivers.caregivers.length
        : aines.aines.length;

    final relationLabel = auth.isAine ? "Aidants" : "Aînés";
    final relationIcon = auth.isAine ? Icons.people : Icons.elderly;

    final progress = isProcheSansAine
        ? 0.0
        : activity.isLoading
        ? 0.0
        : activity.todayActivity.progressRatio;

    final activityData = isProcheSansAine ? null : activity.todayActivity;

    final rappelsDuJour = isProcheSansAine ? [] : rappelProvider.rappelsDuJour;

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(context, auth),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004E92), Color(0xFF000428)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopHeader(auth, nbDemandes, aines),
              const SizedBox(height: 12),
              _buildDatePill(),
              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildStatCard(
                      value: remainingMeds.toString().padLeft(2, '0'),
                      label: "À prendre",
                      icon: Icons.medication,
                      color: const Color(0xFF8370D8),
                      disabled: isProcheSansAine,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      value: missedMeds.toString().padLeft(2, '0'),
                      label: "Non pris",
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFE86C5D),
                      disabled: isProcheSansAine,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      value: activeReminders.toString().padLeft(2, '0'),
                      label: "Rappels",
                      icon: Icons.notifications_active,
                      color: const Color(0xFF5D95D6),
                      disabled: isProcheSansAine,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      value: relationCount.toString().padLeft(2, '0'),
                      label: relationLabel,
                      icon: relationIcon,
                      color: const Color(0xFF51A091),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF8F4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (isProcheSansAine) _selectAineNotice(context),

                        _sectionHeader(
                          "Activité du jour",
                          isProcheSansAine
                              ? "Choisir un aîné ↗"
                              : "Voir détails ↗",
                          () => Navigator.pushNamed(
                            context,
                            isProcheSansAine ? '/aine' : '/activities_daily',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _activityCard(
                          progress,
                          activityData,
                          disabled: isProcheSansAine,
                        ),

                        const SizedBox(height: 18),

                        _sectionHeader(
                          "Médicaments du jour",
                          isProcheSansAine
                              ? "Choisir un aîné ↗"
                              : "Tout voir ↗",
                          () => Navigator.pushNamed(
                            context,
                            isProcheSansAine ? '/aine' : '/medications',
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (isProcheSansAine)
                          _disabledInfoBox(
                            "Sélectionnez un aîné pour afficher ses médicaments.",
                          )
                        else if (activeMeds.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: TrText(
                              "Aucun médicament ajouté",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...activeMeds.map(
                            (med) => _medicationTile(context, med),
                          ),

                        const SizedBox(height: 12),
                        if (!isProcheSansAine) _warningCard(remainingMeds),

                        const SizedBox(height: 18),

                        _sectionHeader(
                          "Rappels du jour",
                          isProcheSansAine
                              ? "Choisir un aîné ↗"
                              : "Tout voir ↗",
                          () => Navigator.pushNamed(
                            context,
                            isProcheSansAine ? '/aine' : '/rappel',
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (isProcheSansAine)
                          _disabledInfoBox(
                            "Sélectionnez un aîné pour afficher ses rappels.",
                          )
                        else if (rappelsDuJour.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: TrText(
                              "Aucun rappel aujourd’hui",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          ...rappelsDuJour.map((r) => _rappelTile(r)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectAineNotice(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          const Expanded(
            child: TrText(
              "Sélectionnez un aîné pour afficher ses informations.",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/aine'),
            child: const TrText("Choisir"),
          ),
        ],
      ),
    );
  }

  Widget _disabledInfoBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EFEA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TrText(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget displayImage(String? path) {
    if (path == null || path.isEmpty) {
      return Image.asset('images/giphy.gif');
    }

    if (path.startsWith('http')) {
      return Image.network(path);
    } else {
      return Image.file(File(path));
    }
  }

  Widget _activityCard(
    double progress,
    dynamic activity, {
    bool disabled = false,
  }) {
    final int steps = disabled ? 0 : activity.steps;
    final int stepGoal = disabled ? 0 : activity.stepGoal;

    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 85,
                  height: 85,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: progress.clamp(0.0, 1.0),
                    ),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, _) {
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 9,
                        backgroundColor: const Color(0xFFF1F5F9),
                        color: const Color(0xFF10B981),
                        strokeCap: StrokeCap.round,
                      );
                    },
                  ),
                ),
                const Icon(
                  Icons.directions_walk_rounded,
                  color: Color(0xFF10B981),
                  size: 30,
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$steps",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TrText(
                    "Objectif : $stepGoal",
                    isDynamic: true,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${(progress * 100).toInt()}% accompli",
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      backgroundColor: const Color(0xFF001F3F),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF001429)),
            child: Center(
              child: Image.asset('images/logoProConnectNB.png', height: 125),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  Icons.dashboard,
                  "Tableau de bord",
                  () => Navigator.pop(context),
                  isActive: true,
                ),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _drawerItem(
                  Icons.medication,
                  "Médicaments",
                  () => Navigator.pushNamed(context, '/medications'),
                ),
                _drawerItem(
                  Icons.directions_run,
                  "Activités",
                  () => Navigator.pushNamed(context, '/activities'),
                ),
                _drawerItem(
                  auth.isAine ? Icons.people : Icons.elderly,
                  auth.isAine ? "Proche aidant" : "Aînés",
                  () => Navigator.pushNamed(
                    context,
                    auth.isAine ? '/caregiver' : '/aine',
                  ),
                ),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _drawerItem(
                  Icons.notifications_active,
                  "Rappels",
                  () => Navigator.pushNamed(context, '/rappel'),
                ),
                _drawerItem(
                  Icons.calendar_month,
                  "Rendez-vous",
                  () => Navigator.pushNamed(context, '/appointments'),
                ),
                _drawerItem(
                  Icons.history,
                  "Historique médicaments",
                  () => Navigator.pushNamed(context, '/medicationHistory'),
                ),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _drawerItem(
                  Icons.calendar_month,
                  "Paramètres",
                  () => Navigator.pushNamed(context, '/settings'),
                ),
                const Divider(color: Colors.white24, indent: 20, endIndent: 20),
                _drawerItem(Icons.logout, "Se déconnecter", () async {
                  final navigator = Navigator.of(context);
                  await auth.logout();
                  if (!mounted) return;
                  navigator.pushNamedAndRemoveUntil('/login', (_) => false);
                }, color: Colors.redAccent),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isActive = false,
    Color color = Colors.white,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: TrText(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildTopHeader(
    AuthProvider auth,
    int nbDemandes,
    AineProvider aines,
  ) {
    final selectedAine = aines.selectedAine;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
            onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TrText(
                  "Bienvenue",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                TrText(
                  auth.firstName ?? "Utilisateur",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (auth.isAidant)
                  Text(
                    selectedAine == null
                        ? "Aucun aîné sélectionné"
                        : "Aîné actif : ${selectedAine.prenom} ${selectedAine.nom}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: auth.isAidant ? Colors.white : Colors.white38,
                ),
                onPressed: auth.isAidant
                    ? () => Navigator.pushNamed(context, '/demandeRecue')
                    : null,
              ),

              if (auth.isAidant && nbDemandes > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      nbDemandes.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/editprofil'),
            child: _buildHeaderImage(auth),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePill() {
    String dateFormatee = DateFormat(
      'EEEE d MMMM',
      'fr_FR',
    ).format(DateTime.now());

    dateFormatee = dateFormatee[0].toUpperCase() + dateFormatee.substring(1);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, color: Colors.white70, size: 14),
            const SizedBox(width: 6),
            TrText(
              dateFormatee,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      children: [
        TrText(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: TrText(
            action,
            style: const TextStyle(
              color: Color(0xFF5D95D6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    bool disabled = false,
  }) {
    return Expanded(
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Container(
          height: 104,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TrText(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _medicationTile(BuildContext context, dynamic med) {
   // final isTaken = med.isTaken;
    final isActive = med.isActive;

    return Opacity(
      opacity: isActive ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF1EFEA),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 4,
              backgroundColor: !isActive
                  ? Colors.grey
                  : med.status == 'pris'
                  ? const Color(0xFF6FC27B)
                  : med.status == 'nonPris'
                  ? Colors.red
                  : const Color(0xFFFFB547),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${med.name} ${med.dosage}",
                    style: TextStyle(
                      color: isActive ? const Color(0xFF4E4944) : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: isActive ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${med.time} - ",
                        style: const TextStyle(
                          color: Color(0xFF8A8178),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TrText(
                        !isActive
                            ? "désactivé"
                            : med.status == 'pris'
                            ? "pris"
                            : med.status == 'nonPris'
                            ? "non pris"
                            : "à prendre",
                        style: const TextStyle(
                          color: Color(0xFF8A8178),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isActive)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  med.status == 'pris'
                      ? Icons.check_circle
                      : med.status == 'nonPris'
                      ? Icons.cancel
                      : Icons.radio_button_unchecked,
                  color: med.status == 'pris'
                      ? const Color(0xFF61B66D)
                      : med.status == 'nonPris'
                      ? Colors.red
                      : const Color(0xFFFFB547),
                  size: 22,
                ),
                onPressed: () =>
                    context.read<MedicationProvider>().toggleTaken(med.id),
              )
            else
              const TrText(
                "Inactif",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _warningCard(int remaining) {
    if (remaining == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 10),
          TrText(
            "$remaining médicament(s) restant(s)",
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rappelTile(dynamic r) {
    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title: Text(r.type),
      subtitle: Text(r.description ?? ""),
    );
  }

  Widget _buildHeaderImage(AuthProvider auth) {
    final String? path = auth.profilePicture;

    ImageProvider? imageProvider;

    if (path != null && path.isNotEmpty) {
      if (path.startsWith('http')) {
        imageProvider = NetworkImage(path);
      } else {
        imageProvider = FileImage(File(path));
      }
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white24,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, color: Colors.white, size: 24)
          : null,
    );
  }
}
