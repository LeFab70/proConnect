import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/rappel.dart';
import '../../models/medication.dart';
import '../../provider/auth_provider.dart';
import '../../provider/medication_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../services/notification_service.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<MedicationProvider>().fetchMedications(auth);
      context.read<RappelProvider>().fetchRappels(auth);
    });
  }

  String _heureBackend(String schedule) {
    final parts = schedule.split(':');
    final h = (parts.isNotEmpty ? parts[0] : '08').padLeft(2, '0');
    final m = (parts.length > 1 ? parts[1] : '0').padLeft(2, '0');
    return '$h:$m:00';
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  DateTime _buildDateTimeFromTime(String time) {
    final now = DateTime.now();
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? now.hour;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> _createOrRemoveRappels({
    required Medication med,
    required bool value,
  }) async {
    final medicationProvider = context.read<MedicationProvider>();
    final rappelProvider = context.read<RappelProvider>();
    final auth = context.read<AuthProvider>();

    await medicationProvider.toggleActive(med.id, value, auth);

    final medicamentId = int.tryParse(med.id);
    if (medicamentId == null) return;

    await rappelProvider.deleteRappelByMedicamentId(medicamentId, auth);
    if (!value) return;

    for (final schedule in med.schedules) {
      var dateHeurePrise = _buildDateTimeFromTime(schedule);
      const minutesAvant = 10;

      if (dateHeurePrise.isBefore(DateTime.now())) {
        dateHeurePrise = dateHeurePrise.add(const Duration(days: 1));
      }

      final rappel = Rappel(
        id: DateTime.now().microsecondsSinceEpoch,
        dateDebut: DateTime.now(),
        heureDebut: _heureBackend(schedule),
        minutesAvantRappel: minutesAvant,
        dateHeurePrise: dateHeurePrise,
        dateHeureNotification: dateHeurePrise.subtract(
          const Duration(minutes: minutesAvant),
        ),
        type: 'Medicament',
        actif: true,
        medicamentId: medicamentId,
        groupeId: 'med_$medicamentId',
      );

      await rappelProvider.addRappel(rappel, auth);
    }

    await rappelProvider.fetchRappels(auth);

    for (final r
        in rappelProvider.rappels.where((x) => x.medicamentId == medicamentId)) {
      try {
        await NotificationService.scheduleDailyRappel(
          id: r.id,
          title: 'Rappel médicament',
          body: 'Il est temps de prendre ${med.name}',
          dateTime: r.dateHeureNotification,
        );
      } catch (_) {}
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _isDeleting = true);

    final medicationProvider = context.read<MedicationProvider>();
    final rappelProvider = context.read<RappelProvider>();
    final auth = context.read<AuthProvider>();
    bool allSuccess = true;

    for (final id in _selectedIds.toList()) {
      final medId = int.tryParse(id);
      if (medId != null) {
        await rappelProvider.deleteRappelByMedicamentId(medId, auth);
      }
      final success =
          await medicationProvider.deleteMedication(id, auth: auth);
      if (!success) allSuccess = false;
    }

    if (!mounted) return;

    setState(() {
      _isDeleting = false;
      _selectedIds.clear();
    });

    _showSnackBar(
      allSuccess ? 'Traitements supprimés' : 'Erreur lors de la suppression',
      isError: !allSuccess,
    );
  }

  void _openEditScreen(Medication med) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationScreen(
          id: med.id,
          initialName: med.name,
          initialMarque: med.marque,
          initialDosage: med.dosage,
          initialSchedules: med.schedules,
          initialUrlPhoto: med.urlPhoto,
          initialAineId: med.aineId,
          initialIsActive: med.isActive,
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? const Color(0xFFEF4444)
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  Widget _buildMedicationAvatar(Medication med, bool isSelected) {
    if (isSelected) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF4A9FE8),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF7DC4FF), width: 1.5),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 22),
      );
    }

    if (med.urlPhoto != null && med.urlPhoto!.trim().isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF4A9FE8).withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            med.urlPhoto!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _defaultAvatar(med),
          ),
        ),
      );
    }

    return _defaultAvatar(med);
  }

  Widget _defaultAvatar(Medication med) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: med.isActive
            ? const Color(0xFF004E92).withOpacity(0.5)
            : Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(
          color: med.isActive
              ? const Color(0xFF4A9FE8).withOpacity(0.35)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.medication_rounded,
        color: med.isActive
            ? const Color(0xFF7DC4FF)
            : Colors.white.withOpacity(0.25),
        size: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final hasSelection = _selectedIds.isNotEmpty;

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
                      const Color(0xFF004E92).withOpacity(0.5),
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
                  _buildHeader(context, hasSelection),
                  Expanded(
                    child: Consumer<MedicationProvider>(
                      builder: (context, provider, child) {
                        final meds = provider.medications
                            .where((med) => !med.isDeleted)
                            .toList();

                        if (meds.isEmpty) return _buildEmptyState();

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                          itemCount: meds.length,
                          itemBuilder: (context, index) {
                            final med = meds[index];
                            final isSelected = _selectedIds.contains(med.id);
                            return _buildMedicationCard(med, isSelected);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: hasSelection
          ? FloatingActionButton.extended(
              onPressed: _isDeleting ? null : _deleteSelected,
              backgroundColor: const Color(0xFFEF4444),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                'Supprimer (${_selectedIds.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMedicationScreen(),
                  ),
                );
              },
              backgroundColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(Icons.add_rounded, color: Color(0xFF004E92)),
              label: const Text(
                'Nouveau traitement',
                style: TextStyle(
                  color: Color(0xFF004E92),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, bool hasSelection) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (hasSelection) {
                setState(() => _selectedIds.clear());
              } else {
                Navigator.pop(context);
              }
            },
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
              child: Icon(
                hasSelection
                    ? Icons.close_rounded
                    : Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            children: [
              Text(
                hasSelection
                    ? '${_selectedIds.length} sélectionné(s)'
                    : 'Traitements',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (!hasSelection)
                Consumer<MedicationProvider>(
                  builder: (_, provider, __) {
                    final count = provider.medications
                        .where((m) => !m.isDeleted)
                        .length;
                    return Text(
                      '$count traitement(s)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.medication_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun traitement en cours',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier traitement',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Medication med, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (_selectedIds.isNotEmpty) {
          _toggleSelection(med.id);
        } else {
          _openEditScreen(med);
        }
      },
      onLongPress: () => _toggleSelection(med.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.16)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.55)
                : Colors.white.withOpacity(0.11),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000428).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => _toggleSelection(med.id),
              child: _buildMedicationAvatar(med, isSelected),
            ),

            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: med.isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
                      decoration: med.isActive
                          ? null
                          : TextDecoration.lineThrough,
                      decorationColor: Colors.white.withOpacity(0.3),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Marque + dosage
                  Row(
                    children: [
                      if ((med.marque ?? '').isNotEmpty) ...[
                        Icon(
                          Icons.local_pharmacy_outlined,
                          size: 12,
                          color: Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          med.marque ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        med.dosage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Horaires sous forme de chips
                  if (med.schedules.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: med.schedules.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: med.isActive
                                ? const Color(0xFF004E92).withOpacity(0.4)
                                : Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: med.isActive
                                  ? const Color(0xFF4A9FE8).withOpacity(0.3)
                                  : Colors.white.withOpacity(0.07),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 10,
                                color: med.isActive
                                    ? const Color(0xFF7DC4FF).withOpacity(0.8)
                                    : Colors.white.withOpacity(0.2),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                s,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: med.isActive
                                      ? const Color(0xFF7DC4FF)
                                      : Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 6),

                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: med.isActive
                          ? const Color(0xFF10B981).withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: med.isActive
                            ? const Color(0xFF10B981).withOpacity(0.35)
                            : Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      med.isActive ? '● Rappel actif' : '○ Désactivé',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: med.isActive
                            ? const Color(0xFF34D399)
                            : Colors.white.withOpacity(0.25),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Switch
            Transform.scale(
              scale: 0.85,
              child: Switch(
                value: med.isActive,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF004E92),
                inactiveThumbColor: Colors.white.withOpacity(0.3),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                onChanged: (value) async {
                  await _createOrRemoveRappels(med: med, value: value);
                },
              ),
            ),

            const SizedBox(width: 6),

            // Checkbox sélection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A9FE8)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4A9FE8)
                      : Colors.white.withOpacity(0.22),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
