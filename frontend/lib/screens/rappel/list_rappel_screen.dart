import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../provider/appointment_provider.dart';
import '../../models/rappel.dart';
import '../../provider/auth_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../provider/medication_provider.dart';
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
      final auth = context.read<AuthProvider>();
      final provider = context.read<RappelProvider>();

      if (provider.rappels.isEmpty) {
        await provider.fetchRappels(auth);
      } else {
        debugPrint(
          "FETCH RAPPELS ignoré : rappels locaux déjà présents (${provider.rappels.length})",
        );
      }
    });
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month à $hour:$minute';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _deleteSelected(BuildContext context) async {
    final provider = context.read<RappelProvider>();
    final auth = context.read<AuthProvider>();

    for (final id in _selectedIds) {
      await provider.deleteRappel(id, auth);
    }

    setState(() => _selectedIds.clear());

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Rappel(s) supprimé(s).',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final provider = context.watch<RappelProvider>();
    final rappels = provider.rappels;
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
                  _buildHeader(context, rappels, hasSelection),
                  Expanded(
                    child: rappels.isEmpty
                        ? _buildEmptyState()
                        : _buildList(rappels),
                  ),
                ],
              ),
            ),
          ],
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddRappelScreen()),
              ),
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
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
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
                    : 'Rappels',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
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
                        width: 1,
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
              Icons.alarm_outlined,
              size: 48,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Aucun rappel disponible',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre premier rappel',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
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
          ...actifs.map((r) => _buildRappelCard(r)),
        ],
        if (inactifs.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildSectionLabel(
            'Inactifs',
            Icons.notifications_off_outlined,
            Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 10),
          ...inactifs.map((r) => _buildRappelCard(r)),
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

  Widget _buildRappelCard(Rappel rappel) {
    final isSelected = _selectedIds.contains(rappel.id);
    final isActif = rappel.actif;

    return GestureDetector(
      onTap: () {
        if (_selectedIds.isNotEmpty) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(rappel.id);
            } else {
              _selectedIds.add(rappel.id);
            }
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RappelDetailScreen(rappel: rappel),
            ),
          );
        }
      },

      onLongPress: () {
        setState(() {
          if (isSelected) {
            _selectedIds.remove(rappel.id);
          } else {
            _selectedIds.add(rappel.id);
          }
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
            // Icône statut
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: isActif
                    ? const Color(0xFF10B981).withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.05),

                shape: BoxShape.circle,

                border: Border.all(
                  color: isActif
                      ? const Color(0xFF10B981).withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),

              child: Icon(
                isActif
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,

                color: isActif
                    ? const Color(0xFF34D399)
                    : Colors.white.withValues(alpha: 0.25),

                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer2<MedicationProvider, AppointmentProvider>(
                    builder:
                        (context, medicationProvider, appointmentProvider, _) {
                          final med = rappel.medicamentId == null
                              ? null
                              : medicationProvider.getMedicationById(
                                  rappel.medicamentId.toString(),
                                );

                          RendezVousMedical? rdv;

                          if (rappel.rendezVousMedicalId != null) {
                            for (final a in appointmentProvider.appointments) {
                              if (a.id == rappel.rendezVousMedicalId) {
                                rdv = a;
                                break;
                              }
                            }
                          }

                          String title;

                          if (med != null) {
                            title = 'Médicament : ${med.name}';
                          } else if (rdv != null) {
                            title = 'Rendez-vous : ${rdv.docteur}';
                          } else if (rappel.type == 'RendezVousMedical') {
                            title = 'Rendez-vous médical';
                          } else {
                            title = rappel.type;
                          }

                          return Text(
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

                              decorationColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                  ),

                  const SizedBox(height: 6),

                  // Notification + Prise
                  Row(
                    children: [
                      _buildTimePill(
                        Icons.notifications_rounded,
                        _formatDateTime(rappel.dateHeureNotification),

                        isActif
                            ? const Color(0xFF7DC4FF)
                            : Colors.white.withValues(alpha: 0.2),

                        isActif,
                      ),

                      const SizedBox(width: 6),

                      _buildTimePill(
                        Icons.medication_rounded,
                        _formatTime(rappel.dateHeurePrise),

                        isActif
                            ? const Color(0xFF34D399)
                            : Colors.white.withValues(alpha: 0.2),

                        isActif,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Toggle actif/inactif
            Switch(
              value: isActif,

              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF10B981),

              inactiveThumbColor: Colors.white.withValues(alpha: 0.4),

              inactiveTrackColor: Colors.white.withValues(alpha: 0.12),

              onChanged: (value) async {
                final auth = context.read<AuthProvider>();

                await context.read<RappelProvider>().toggleRappel(
                  rappel.id,
                  value,
                  auth,
                );
              },
            ),

            const SizedBox(width: 6),

            // Sélection
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
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
