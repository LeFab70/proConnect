import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/medication.dart';
import '../../models/rappel.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/medication_provider.dart';
import '../../provider/rappel_provider.dart';

/// Bloc affiché en haut de l'écran « cloche » : rappels médicaments / RDV avec libellés.
class RappelsBellInboxSection extends StatefulWidget {
  /// Si non null et > 0, ne garde que les rappels liés à cet aîné (côté aidant ou aîné).
  final int? filterAineId;

  const RappelsBellInboxSection({super.key, this.filterAineId});

  @override
  State<RappelsBellInboxSection> createState() => _RappelsBellInboxSectionState();
}

class _RappelsBellInboxSectionState extends State<RappelsBellInboxSection> {
  bool _prefetchDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefetchDone) return;
    _prefetchDone = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.token == null || auth.token!.isEmpty) return;
      await Future.wait([
        context.read<RappelProvider>().fetchRappels(auth),
        context.read<MedicationProvider>().fetchMedications(auth),
        context.read<AppointmentProvider>().fetchAppointments(auth),
      ]);
    });
  }

  Medication? _medFor(Rappel r, MedicationProvider medProv) {
    if (r.medicamentId == null) return null;
    for (final m in medProv.medications) {
      if (m.id == r.medicamentId.toString()) return m;
      final parsed = int.tryParse(m.id);
      if (parsed != null && parsed == r.medicamentId) return m;
    }
    return null;
  }

  bool _matchesAine(
    Rappel r,
    int aineId,
    MedicationProvider medProv,
    AppointmentProvider apptProv,
  ) {
    if (r.medicamentId != null) {
      final m = _medFor(r, medProv);
      return m != null && m.aineId == aineId;
    }
    if (r.rendezVousMedicalId != null) {
      final rdv = apptProv.getAppointmentById(r.rendezVousMedicalId!);
      return rdv != null && rdv.aineId == aineId;
    }
    return true;
  }

  List<Rappel> _visibleRappels(
    RappelProvider rappels,
    MedicationProvider medProv,
    AppointmentProvider apptProv,
  ) {
    final now = DateTime.now();
    final pastCut = now.subtract(const Duration(days: 1));
    final futureCut = now.add(const Duration(days: 14));

    final list = rappels.rappels.where((r) {
      if (!r.actif) return false;
      if (r.dateHeureNotification.isBefore(pastCut)) return false;
      if (r.dateHeureNotification.isAfter(futureCut)) return false;
      final fid = widget.filterAineId;
      if (fid != null && fid > 0) {
        if (!_matchesAine(r, fid, medProv, apptProv)) return false;
      }
      return true;
    }).toList()
      ..sort(
        (a, b) => a.dateHeureNotification.compareTo(b.dateHeureNotification),
      );

    return list;
  }

  String _titleLine(Rappel r, MedicationProvider medProv, AppointmentProvider apptProv) {
    if (r.type.toLowerCase().contains('medicament') && r.medicamentId != null) {
      final m = _medFor(r, medProv);
      final name = m?.name.trim().isNotEmpty == true ? m!.name : 'Médicament';
      final dose = m?.dosage.trim().isNotEmpty == true ? ' — ${m!.dosage}' : '';
      return 'Médicament : $name$dose';
    }
    if (r.rendezVousMedicalId != null) {
      final rdv = apptProv.getAppointmentById(r.rendezVousMedicalId!);
      if (rdv != null) {
        final doc = rdv.docteur.trim().isNotEmpty ? rdv.docteur : 'Médecin';
        final lieu = rdv.lieu.trim().isNotEmpty ? ' — ${rdv.lieu}' : '';
        return 'Rendez-vous : Dr $doc$lieu';
      }
      return 'Rendez-vous #${r.rendezVousMedicalId}';
    }
    return 'Rappel';
  }

  @override
  Widget build(BuildContext context) {
    final rappelProv = context.watch<RappelProvider>();
    final medProv = context.watch<MedicationProvider>();
    final apptProv = context.watch<AppointmentProvider>();

    final items = _visibleRappels(rappelProv, medProv, apptProv);
    if (items.isEmpty) return const SizedBox.shrink();

    final fmt = DateFormat("EEE d MMM · HH:mm", 'fr');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              size: 16,
              color: Colors.amber.shade300,
            ),
            const SizedBox(width: 8),
            Text(
              'Rappels & alertes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.amber.shade200,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((r) {
          final isPast = !r.dateHeureNotification.isAfter(DateTime.now());
          final color = isPast
              ? const Color(0xFF94A3B8)
              : const Color(0xFF38BDF8);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isPast ? 0.05 : 0.09),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    r.medicamentId != null
                        ? Icons.medication_rounded
                        : Icons.event_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleLine(r, medProv, apptProv),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPast
                            ? 'Prévu : ${fmt.format(r.dateHeureNotification)} (passé)'
                            : 'Notification : ${fmt.format(r.dateHeureNotification)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/rappel'),
                  tooltip: 'Rappels',
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha: 0.12), height: 1),
        const SizedBox(height: 16),
      ],
    );
  }
}
