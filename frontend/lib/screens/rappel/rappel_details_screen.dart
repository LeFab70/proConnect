import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/rappel.dart';
import '../../provider/rappel_provider.dart';
import 'add_rappel_screen.dart';
import '../../widgets/tr_text.dart';

class RappelDetailScreen extends StatelessWidget {
  final Rappel rappel;

  const RappelDetailScreen({super.key, required this.rappel});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_formatDate(date)} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final provider = context.watch<RappelProvider>();
    final currentRappel = provider.rappels.firstWhere(
      (r) => r.id == rappel.id,
      orElse: () => rappel,
    );

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
                  _buildHeader(context, currentRappel),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      child: Column(
                        children: [
                          _buildHeroCard(currentRappel),
                          const SizedBox(height: 16),
                          _buildTimingCard(currentRappel),
                          const SizedBox(height: 16),
                          _buildDetailsCard(currentRappel),
                          const SizedBox(height: 24),
                          _buildEditButton(context, currentRappel),
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

  Widget _buildHeader(BuildContext context, Rappel currentRappel) {
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

          const TrText(
            'Détail du rappel',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),

          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddRappelScreen(rappel: currentRappel),
              ),
            ),
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
                Icons.edit_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO CARD ─────────────────────────────────────────────────────────────

  Widget _buildHeroCard(Rappel currentRappel) {
    final isActif = currentRappel.actif;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isActif
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isActif
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActif
                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActif
                    ? const Color(0xFF10B981).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isActif
                  ? [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isActif
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              color: isActif
                  ? const Color(0xFF34D399)
                  : Colors.white.withValues(alpha: 0.25),
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentRappel.type,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isActif
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                    decoration: isActif ? null : TextDecoration.lineThrough,
                    decorationColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isActif
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActif
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActif
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 12,
                        color: isActif
                            ? const Color(0xFF34D399)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isActif ? 'Rappel actif' : 'Rappel désactivé',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActif
                              ? const Color(0xFF34D399)
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TIMING CARD ───────────────────────────────────────────────────────────

  Widget _buildTimingCard(Rappel currentRappel) {
    return _buildGlassCard(
      sectionIcon: Icons.schedule_rounded,
      sectionTitle: 'Horaires',
      children: [
        _buildInfoRow(
          Icons.notifications_rounded,
          'Notification prévue',
          _formatDateTime(currentRappel.dateHeureNotification),
          valueColor: const Color(0xFF7DC4FF),
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.medication_rounded,
          'Heure de prise',
          _formatDateTime(currentRappel.dateHeurePrise),
          valueColor: const Color(0xFF34D399),
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.timer_outlined,
          'Délai avant rappel',
          '${currentRappel.minutesAvantRappel} minute(s) avant',
        ),
      ],
    );
  }

  // ─── DETAILS CARD ──────────────────────────────────────────────────────────

  Widget _buildDetailsCard(Rappel currentRappel) {
    return _buildGlassCard(
      sectionIcon: Icons.info_outline_rounded,
      sectionTitle: 'Informations',
      children: [
        _buildInfoRow(
          Icons.calendar_today_rounded,
          'Date de début',
          _formatDate(currentRappel.dateDebut),
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.access_time_rounded,
          'Heure de début',
          currentRappel.heureDebut,
        ),
        if (currentRappel.medicamentId != null) ...[
          _buildDivider(),
          _buildInfoRow(
            Icons.local_pharmacy_outlined,
            'ID Médicament',
            '#${currentRappel.medicamentId}',
            valueColor: const Color(0xFF7DC4FF),
          ),
        ],
        if (currentRappel.rendezVousMedicalId != null) ...[
          _buildDivider(),
          _buildInfoRow(
            Icons.event_outlined,
            'ID Rendez-vous',
            '#${currentRappel.rendezVousMedicalId}',
            valueColor: const Color(0xFF7DC4FF),
          ),
        ],
        if (currentRappel.groupeId != null) ...[
          _buildDivider(),
          _buildInfoRow(
            Icons.group_work_outlined,
            'Groupe',
            currentRappel.groupeId!,
          ),
        ],
      ],
    );
  }

  // ─── GLASS CARD ────────────────────────────────────────────────────────────

  Widget _buildGlassCard({
    required IconData sectionIcon,
    required String sectionTitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  sectionIcon,
                  color: const Color(0xFF7DC4FF),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                sectionTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: value.isEmpty
                        ? Colors.white.withValues(alpha: 0.25)
                        : (valueColor ?? Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 18,
      indent: 29,
    );
  }

  // ─── BOUTON ÉDITER ─────────────────────────────────────────────────────────

  Widget _buildEditButton(BuildContext context, Rappel currentRappel) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004E92).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddRappelScreen(rappel: currentRappel),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            TrText(
              'Modifier le rappel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
