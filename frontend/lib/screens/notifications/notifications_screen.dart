import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/medication_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final medProvider = context.watch<MedicationProvider>();
    final activeMeds = medProvider.activeMedications;

    final taken = activeMeds.where((m) => m.isTaken).toList();
    final pending = activeMeds.where((m) => !m.isTaken).toList();

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
                  gradient: RadialGradient(colors: [
                    const Color(0xFF004E92).withOpacity(0.5),
                    Colors.transparent,
                  ]),
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
                  gradient: RadialGradient(colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, activeMeds.length, pending.length),
                  Expanded(
                    child: activeMeds.isEmpty
                        ? _buildEmptyState()
                        : _buildList(pending, taken),
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

  Widget _buildHeader(
      BuildContext context, int total, int pendingCount) {
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
                    color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.white),
            ),
          ),

          Column(
            children: [
              const Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (total > 0)
                Text(
                  "$pendingCount à prendre",
                  style: TextStyle(
                    fontSize: 12,
                    color: pendingCount > 0
                        ? const Color(0xFFFF7070)
                        : Colors.white.withOpacity(0.45),
                    fontWeight: FontWeight.w600,
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
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 48, color: Colors.white.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune notification active",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Activez des rappels pour les voir ici",
            style: TextStyle(
                color: Colors.white.withOpacity(0.3), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── LIST ──────────────────────────────────────────────────────────────────

  Widget _buildList(List pending, List taken) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        if (pending.isNotEmpty) ...[
          _buildSectionLabel(
            "À prendre",
            Icons.alarm_rounded,
            const Color(0xFFFF7070),
          ),
          const SizedBox(height: 10),
          ...pending.map((med) => _buildNotifCard(med, false)),
        ],
        if (taken.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionLabel(
            "Déjà pris",
            Icons.check_circle_outline_rounded,
            const Color(0xFF34D399),
          ),
          const SizedBox(height: 10),
          ...taken.map((med) => _buildNotifCard(med, true)),
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

  // ─── NOTIFICATION CARD ─────────────────────────────────────────────────────

  Widget _buildNotifCard(dynamic med, bool isTaken) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTaken
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isTaken
              ? Colors.white.withOpacity(0.07)
              : const Color(0xFFEF4444).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: isTaken
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF000428).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isTaken
                  ? const Color(0xFF10B981).withOpacity(0.12)
                  : const Color(0xFFEF4444).withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isTaken
                    ? const Color(0xFF10B981).withOpacity(0.3)
                    : const Color(0xFFEF4444).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              isTaken
                  ? Icons.check_rounded
                  : Icons.medication_rounded,
              color: isTaken
                  ? const Color(0xFF34D399)
                  : const Color(0xFFFF7070),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rappel de médicament",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.45),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  med.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isTaken
                        ? Colors.white.withOpacity(0.4)
                        : Colors.white,
                    decoration:
                        isTaken ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoPill(
                      Icons.monitor_weight_outlined,
                      med.dosage,
                      isTaken,
                    ),
                    const SizedBox(width: 6),
                    _buildInfoPill(
                      Icons.access_time_rounded,
                      med.time,
                      isTaken,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTaken
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTaken
                          ? const Color(0xFF10B981).withOpacity(0.35)
                          : const Color(0xFFEF4444).withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTaken
                            ? Icons.check_circle_outline_rounded
                            : Icons.schedule_rounded,
                        size: 11,
                        color: isTaken
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFF7070),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTaken ? "Déjà pris" : "À prendre",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isTaken
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFF7070),
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

  Widget _buildInfoPill(IconData icon, String label, bool isTaken) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color: Colors.white.withOpacity(isTaken ? 0.25 : 0.45)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white
                  .withOpacity(isTaken ? 0.25 : 0.55),
            ),
          ),
        ],
      ),
    );
  }
}