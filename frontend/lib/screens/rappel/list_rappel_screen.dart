import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/appointment.dart';
import '../../models/rappel.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/medication_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/app_background.dart';
import 'add_rappel_screen.dart';
import 'rappel_details_screen.dart';

class ListRappelScreen extends StatefulWidget {
  const ListRappelScreen({super.key});

  @override
  State<ListRappelScreen> createState() => _ListRappelScreenState();
}

class _ListRappelScreenState extends State<ListRappelScreen> {
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _reloadData();
    });
  }

  Future<void> _reloadData() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();

    await context.read<AppointmentProvider>().fetchAppointments(auth);
    await context.read<MedicationProvider>().fetchMedications(auth);
    await context.read<RappelProvider>().fetchRappels(auth);
  }

  DateTime _dateHeureEffective(Rappel rappel) {
    return rappel.dateHeurePrise.toLocal();
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year à $hour:$minute';
  }

  Future<void> _openAddRappel() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddRappelScreen()),
    );

    if (changed == true && mounted) {
      await _reloadData();
    }
  }

  Future<void> _openRappelDetail(Rappel rappel) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RappelDetailScreen(rappel: rappel)),
    );

    if (changed == true && mounted) {
      await _reloadData();
    }
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final provider = context.read<RappelProvider>();
    final auth = context.read<AuthProvider>();

    for (final id in _selectedIds) {
      await provider.deleteRappel(id, auth);
    }

    setState(() => _selectedIds.clear());

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Rappel(s) supprimé(s).',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final settings = context.watch<SettingsProvider>();
    final provider = context.watch<RappelProvider>();
    final rappels = provider.rappels;
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, rappels, hasSelection),
              Expanded(
                child: rappels.isEmpty
                    ? _buildEmptyState()
                    : _buildList(rappels),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: hasSelection
          ? FloatingActionButton.extended(
              onPressed: () => _deleteSelected(context),
              backgroundColor: const Color(0xFFEF4444),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(
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
              onPressed: _openAddRappel,
              backgroundColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              icon: const Icon(
                Icons.add_alarm_rounded,
                color: Color(0xFF004E92),
              ),
              label: const Text(
                'Nouveau rappel',
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
    List<Rappel> rappels,
    bool hasSelection,
  ) {
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
                    : 'Rappels',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (!hasSelection)
                Text(
                  '${rappels.where((r) => r.actif).length} actif(s)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          hasSelection
              ? GestureDetector(
                  onTap: () => _deleteSelected(context),
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFFF7070),
                    ),
                  ),
                )
              : const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Aucun rappel disponible',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildList(List<Rappel> rappels) {
    final actifs = rappels.where((r) => r.actif).toList();
    final inactifs = rappels.where((r) => !r.actif).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      children: [
        if (actifs.isNotEmpty) ...[
          _buildSectionLabel(
            'Actifs',
            Icons.notifications_active_rounded,
            const Color(0xFF34D399),
          ),
          const SizedBox(height: 10),
          ...actifs.map(_buildRappelCard),
        ],
        if (inactifs.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionLabel(
            'Inactifs',
            Icons.notifications_off_outlined,
            Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          ...inactifs.map(_buildRappelCard),
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
          ),
        ),
      ],
    );
  }

  Widget _buildRappelCard(Rappel rappel) {
    final isSelected = _selectedIds.contains(rappel.id);
    final isActif = rappel.actif;

    return Consumer2<MedicationProvider, AppointmentProvider>(
      builder: (context, medicationProvider, appointmentProvider, _) {
        final dateEffective = _dateHeureEffective(rappel);

        final med = rappel.medicamentId == null
            ? null
            : medicationProvider.getMedicationById(
                rappel.medicamentId.toString(),
              );

        RendezVousMedical? rdv;
        if (rappel.rendezVousMedicalId != null) {
          rdv = appointmentProvider.getAppointmentById(
            rappel.rendezVousMedicalId!,
          );
        }

        String title;
        if (med != null) {
          title = 'Médicament : ${med.name}';
        } else if (rdv != null) {
          title = 'Rendez-vous : ${rdv.docteur}';
        } else {
          title = rappel.type;
        }

        return Dismissible(
          key: ValueKey(
            "rappel_${rappel.id}_${rappel.dateHeurePrise.microsecondsSinceEpoch}_${rappel.dateHeureNotification.microsecondsSinceEpoch}",
          ),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Supprimer le rappel"),
                    content: const Text(
                      "Voulez-vous vraiment supprimer ce rappel ?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) async {
            final auth = context.read<AuthProvider>();
            await context.read<RappelProvider>().deleteRappel(rappel.id, auth);

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Rappel supprimé")));
          },
          background: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          child: GestureDetector(
            onTap: () async {
              if (_selectedIds.isNotEmpty) {
                setState(() {
                  isSelected
                      ? _selectedIds.remove(rappel.id)
                      : _selectedIds.add(rappel.id);
                });
              } else {
                await _openRappelDetail(rappel);
              }
            },
            onLongPress: () {
              setState(() {
                isSelected
                    ? _selectedIds.remove(rappel.id)
                    : _selectedIds.add(rappel.id);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.11),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isActif
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_off_outlined,
                    color: isActif
                        ? const Color(0xFF34D399)
                        : Colors.white.withValues(alpha: 0.25),
                    size: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isActif
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            decoration: isActif
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildTimePill(
                              Icons.calendar_month_rounded,
                              'Prise : ${_formatDateTime(rappel.dateHeurePrise)}',
                              isActif
                                  ? const Color(0xFF34D399)
                                  : Colors.white.withValues(alpha: 0.2),
                              isActif,
                            ),
                            _buildTimePill(
                              Icons.notifications_rounded,
                              'Notif : ${_formatDateTime(rappel.dateHeureNotification)}',
                              isActif
                                  ? const Color(0xFF7DC4FF)
                                  : Colors.white.withValues(alpha: 0.2),
                              isActif,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isActif,
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF10B981),
                    inactiveThumbColor: Colors.white.withValues(alpha: 0.4),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                    onChanged: (value) async {
                      final now = DateTime.now();

                      if (value && dateEffective.isBefore(now)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Impossible d’activer un rappel dont la date et l’heure sont déjà passées.",
                            ),
                          ),
                        );
                        return;
                      }

                      final auth = context.read<AuthProvider>();

                      await context.read<RappelProvider>().toggleRappel(
                        rappel.id,
                        value,
                        auth,
                      );

                      if (mounted) {
                        await _reloadData();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
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
                            : Colors.white.withValues(alpha: 0.22),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimePill(
    IconData icon,
    String label,
    Color color,
    bool isActif,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActif
            ? color.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActif
              ? color.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
