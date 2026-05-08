import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../provider/auth_provider.dart';
import '../../provider/aine_provider.dart';
import '../../provider/medication_provider.dart';
import '../../widgets/tr_text.dart';

class MedicationHistoryScreen extends StatefulWidget {
  const MedicationHistoryScreen({super.key});

  @override
  State<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedMedicationId;

  Color _statusColor(String status) {
    switch (status) {
      case 'pris':
        return const Color(0xFF10B981);
      case 'nonPris':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pris':
        return Icons.check_circle_outline_rounded;
      case 'nonPris':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pris':
        return 'Pris';
      case 'nonPris':
        return 'Non pris';
      default:
        return 'En attente';
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final auth = context.watch<AuthProvider>();
    final aineProvider = context.watch<AineProvider>();
    final selectedAine = aineProvider.selectedAine;

    final int aineIdActif = selectedAine?.id ?? auth.currentUserLocalId ?? 0;

    final allMeds = context
        .watch<MedicationProvider>()
        .medications
        .where((m) => !m.isDeleted)
        .where((m) => m.aineId == aineIdActif)
        .toList();

    final meds = allMeds.where((m) {
      if (_selectedMedicationId != null && _selectedMedicationId!.isNotEmpty) {
        if (m.id != _selectedMedicationId) return false;
      }

      if (_startDate == null && _endDate == null) return true;

      bool inRange(DateTime? dt) {
        if (dt == null) return false;
        final day = DateTime(dt.year, dt.month, dt.day);
        final startDay = _startDate == null
            ? null
            : DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
        final endDay = _endDate == null
            ? null
            : DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

        if (startDay != null && day.isBefore(startDay)) return false;
        if (endDay != null && day.isAfter(endDay)) return false;
        return true;
      }

      // Show meds that had an event in the selected period (taken/missed)
      return inRange(m.lastTakenAt) || inRange(m.missedAt);
    }).toList();

    final prisList = meds.where((m) => m.status == 'pris').toList();
    final nonPrisList = meds.where((m) => m.status == 'nonPris').toList();
    final attente = meds
        .where((m) => m.status != 'pris' && m.status != 'nonPris')
        .toList();

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
                  _buildHeader(context, meds.length),
                  _buildFilters(allMeds),
                  if (meds.isNotEmpty)
                    _buildSummaryRow(
                      prisList.length,
                      nonPrisList.length,
                      attente.length,
                    ),
                  Expanded(
                    child: meds.isEmpty
                        ? _buildEmptyState()
                        : _buildList(prisList, nonPrisList, attente),
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

  Widget _buildHeader(BuildContext context, int total) {
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
                "Historique",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (total > 0)
                Text(
                  "$total médicament(s)",
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

  Widget _buildFilters(List<dynamic> allMeds) {
    final df = DateFormat('yyyy-MM-dd');
    final startLabel = _startDate == null ? 'Début' : df.format(_startDate!);
    final endLabel = _endDate == null ? 'Fin' : df.format(_endDate!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? now,
                      firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 2),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark(),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _startDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.12 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white.withAlpha((0.55 * 255).round()),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            startLabel,
                            style: TextStyle(
                              color: Colors.white.withAlpha((0.8 * 255).round()),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_startDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _startDate = null),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white.withAlpha((0.5 * 255).round()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? _startDate ?? now,
                      firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 2),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark(),
                        child: child ?? const SizedBox.shrink(),
                      ),
                    );
                    if (!mounted) return;
                    setState(() => _endDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.12 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_available_rounded,
                          size: 14,
                          color: Colors.white.withAlpha((0.55 * 255).round()),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            endLabel,
                            style: TextStyle(
                              color: Colors.white.withAlpha((0.8 * 255).round()),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_endDate != null)
                          GestureDetector(
                            onTap: () => setState(() => _endDate = null),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white.withAlpha((0.5 * 255).round()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.08 * 255).round()),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha((0.12 * 255).round()),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMedicationId,
                      dropdownColor: const Color(0xFF0B1A4A),
                      iconEnabledColor: Colors.white.withAlpha((0.6 * 255).round()),
                      hint: Text(
                        'Tous médicaments',
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.7 * 255).round()),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tous médicaments'),
                        ),
                        ...allMeds.map((m) {
                          return DropdownMenuItem<String>(
                            value: m.id,
                            child: Text(
                              m.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedMedicationId = v);
                      },
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_startDate != null ||
              _endDate != null ||
              (_selectedMedicationId ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedMedicationId = null;
                  }),
                  child: Text(
                    'Réinitialiser les filtres',
                    style: TextStyle(
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── SUMMARY ROW ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow(int pris, int nonPris, int attente) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          _buildSummaryChip(
            pris.toString(),
            "Pris",
            Icons.check_circle_outline_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _buildSummaryChip(
            nonPris.toString(),
            "Non pris",
            Icons.cancel_outlined,
            const Color(0xFFEF4444),
          ),
          const SizedBox(width: 8),
          _buildSummaryChip(
            attente.toString(),
            "En attente",
            Icons.schedule_rounded,
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
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
              Icons.history_rounded,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          TrText(
            "Aucun médicament dans l'historique",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "L'historique apparaîtra ici",
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

  Widget _buildList(List pris, List nonPris, List attente) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      children: [
        if (attente.isNotEmpty) ...[
          _buildSectionLabel(
            "En attente",
            Icons.schedule_rounded,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 10),
          ...attente.map((m) => _buildMedCard(m)),
        ],
        if (pris.isNotEmpty) ...[
          if (attente.isNotEmpty) const SizedBox(height: 8),
          _buildSectionLabel(
            "Pris",
            Icons.check_circle_outline_rounded,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 10),
          ...pris.map((m) => _buildMedCard(m)),
        ],
        if (nonPris.isNotEmpty) ...[
          if (pris.isNotEmpty || attente.isNotEmpty) const SizedBox(height: 8),
          _buildSectionLabel(
            "Non pris",
            Icons.cancel_outlined,
            const Color(0xFFEF4444),
          ),
          const SizedBox(height: 10),
          ...nonPris.map((m) => _buildMedCard(m)),
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

  // ─── MED CARD ──────────────────────────────────────────────────────────────

  Widget _buildMedCard(dynamic med) {
    final statusColor = _statusColor(med.status);
    final statusIcon = _statusIcon(med.status);
    final statusLabel = _statusLabel(med.status);
    final isPris = med.status == 'pris';
    final isNonPris = med.status == 'nonPris';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:isNonPris ? 0.04 : 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isNonPris
              ? const Color(0xFFEF4444).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.11),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne titre + statut ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(statusIcon, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isNonPris
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.white,
                        decoration: isNonPris
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    if ((med.marque ?? '').isNotEmpty)
                      Text(
                        med.marque ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              // Badge statut
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 12),

          // ── Infos pills ──
          const SizedBox(height: 14),
          Divider(
            color: isPris
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.06),
            height: 1,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if ((med.dosage ?? '').isNotEmpty)
                _buildInfoPill(Icons.monitor_weight_outlined, med.dosage ?? ''),
              if (med.schedules != null && med.schedules.isNotEmpty)
                ...med.schedules.map<Widget>(
                  (s) => _buildInfoPill(Icons.access_time_rounded, s),
                ),
              if ((med.frequence ?? '').isNotEmpty)
                _buildInfoPill(Icons.repeat_rounded, med.frequence ?? ''),
            ],
          ),

          const SizedBox(height: 12),

          // ── Ligne statuts ──
          Row(
            children: [
              _buildStatusDot(
                med.isActive ? Icons.check_rounded : Icons.close_rounded,
                med.isActive ? "Actif" : "Inactif",
                med.isActive
                    ? const Color(0xFF34D399)
                    : Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 12),
              if (med.isDeleted)
                _buildStatusDot(
                  Icons.delete_outline_rounded,
                  "Supprimé",
                  const Color(0xFFEF4444),
                ),
            ],
          ),

          // ── Dates ──
          if (med.lastTakenAt != null) ...[
            const SizedBox(height: 10),
            _buildDateRow(
              Icons.check_circle_outline_rounded,
              "Pris le",
              _formatDateTime(med.lastTakenAt),
              const Color(0xFF34D399),
            ),
          ],
          if (med.missedAt != null) ...[
            const SizedBox(height: 6),
            _buildDateRow(
              Icons.cancel_outlined,
              "Non pris le",
              _formatDateTime(med.missedAt),
              const Color(0xFFEF4444),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          "$label : ",
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
