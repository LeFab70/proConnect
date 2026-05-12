import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/caregiver.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/partage_provider.dart';
import '../../models/partage_suivi.dart';
import 'add_caregiver_screen.dart';
import 'caregiver_detail_screen.dart';
import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';

class ListCaregiverScreen extends StatefulWidget {
  const ListCaregiverScreen({super.key});

  @override
  State<ListCaregiverScreen> createState() => _ListCaregiverScreenState();
}

class _ListCaregiverScreenState extends State<ListCaregiverScreen> {
  final Set<int> _selectedCaregiverIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<CaregiverProvider>().fetchCaregivers(auth);
    });
  }

  Widget _buildStatutBadge(StatutPartage statut) {
    Color color;
    String label;
    IconData icon;

    switch (statut) {
      case StatutPartage.actif:
        color = const Color(0xFF10B981);
        label = "Lien établi";
        icon = Icons.check_circle_outline_rounded;
        break;
      case StatutPartage.enAttente:
        color = const Color(0xFFF59E0B);
        label = "En attente";
        icon = Icons.schedule_rounded;
        break;
      case StatutPartage.refuse:
        color = const Color(0xFFEF4444);
        label = "Refusé";
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPartageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off_rounded, size: 11, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 4),
          Text(
            "Non partagé",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, int count) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: TrText(
          "Confirmation",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TrText(
          count == 1
              ? "Supprimer ce proche ?"
              : "Supprimer les $count proches sélectionnés ?",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TrText(
              "Annuler",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const TrText(
              "Supprimer",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    final caregiverProvider = context.watch<CaregiverProvider>();
    final partageProv = context.watch<PartageProvider>();
    final auth = context.watch<AuthProvider>();
    final currentId = auth.currentUserLocalId ?? 0;

    // Pour un aîné : seulement les proches ayant un lien (partage) avec lui.
    // Pour un admin/autre : toute la liste avec statut partage.
    final listAffichage = caregiverProvider.caregivers
        .map((caregiver) {
          PartageSuivi? partage;
          for (final p in partageProv.partages) {
            if (p.aineId == currentId && p.procheAidantId == caregiver.id) {
              partage = p;
              break;
            }
          }
          return {
            'caregiver': caregiver,
            'statut': partage?.statut,
            'aUnPartage': partage != null,
          };
        })
        .where((item) => !auth.isAine || (item['aUnPartage'] as bool))
        .toList();

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, caregiverProvider, partageProv, auth, currentId),
                  Expanded(
                    child: _buildBody(caregiverProvider, listAffichage, partageProv, auth, currentId),
                  ),
                ],
              ),
            ),
      ),

      // Aîné → "Partager mon suivi" (invitation via partage, pas création de compte)
      // Autre → "Ajouter un proche" (création de compte, opération admin)
      floatingActionButton: auth.isAine
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/partageAine'),
              backgroundColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: const Icon(Icons.share_rounded, color: Color(0xFF004E92)),
              label: const Text(
                "Partager mon suivi",
                style: TextStyle(color: Color(0xFF004E92), fontWeight: FontWeight.w800),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCaregiverScreen()),
                );
              },
              backgroundColor: Colors.white,
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF004E92)),
              label: const Text(
                "Ajouter un proche",
                style: TextStyle(color: Color(0xFF004E92), fontWeight: FontWeight.w800),
              ),
            ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    CaregiverProvider caregiverProvider,
    PartageProvider partageProv,
    AuthProvider auth,
    int currentId,
  ) {
    final hasSelection = _selectedCaregiverIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton retour / annuler
          GestureDetector(
            onTap: () {
              if (hasSelection) {
                setState(() => _selectedCaregiverIds.clear());
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              ),
              child: Icon(
                hasSelection ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          // Titre
          Column(
            children: [
              Text(
                hasSelection
                    ? "${_selectedCaregiverIds.length} sélectionné(s)"
                    : "Proches Aidants",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (!hasSelection)
                Text(
                  "${caregiverProvider.caregivers.length} proche(s)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          // Bouton supprimer si sélection, sinon vide
          hasSelection
              ? GestureDetector(
                  onTap: () async {
                    final confirmed = await _confirmDelete(context, _selectedCaregiverIds.length);
                    if (!confirmed) return;

                    final ids = List<int>.from(_selectedCaregiverIds);
                    for (final caregiverId in ids) {
                      final partagesToDelete = partageProv.partages
                          .where((p) => p.aineId == currentId && p.procheAidantId == caregiverId)
                          .map((p) => p.id)
                          .toList();
                      for (final partageId in partagesToDelete) {
                        await partageProv.supprimerPartage(partageId, auth);
                      }
                      await caregiverProvider.deleteCaregiver(caregiverId, auth);
                    }

                    if (mounted) setState(() => _selectedCaregiverIds.clear());
                  },
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

  Widget _buildBody(
    CaregiverProvider caregiverProvider,
    List<Map<String, dynamic>> listAffichage,
    PartageProvider partageProv,
    AuthProvider auth,
    int currentId,
  ) {
    if (caregiverProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
      );
    }

    if (listAffichage.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun proche aidant",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez votre premier proche",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: listAffichage.length,
      itemBuilder: (ctx, index) {
        final item = listAffichage[index];
        final caregiver = item['caregiver'] as Caregiver;
        final statut = item['statut'] as StatutPartage?;
        final aUnPartage = item['aUnPartage'] as bool;
        final isSelected = _selectedCaregiverIds.contains(caregiver.id);

        return GestureDetector(
          onTap: () {
            if (_selectedCaregiverIds.isNotEmpty) {
              setState(() {
                if (isSelected) {
                  _selectedCaregiverIds.remove(caregiver.id);
                } else {
                  _selectedCaregiverIds.add(caregiver.id);
                }
              });
            } else {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => CaregiverDetailScreen(caregiver: caregiver),
                ),
              );
            }
          },
          onLongPress: () {
            setState(() {
              if (isSelected) {
                _selectedCaregiverIds.remove(caregiver.id);
              } else {
                _selectedCaregiverIds.add(caregiver.id);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
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
                // Avatar initiales
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004E92).withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF4A9FE8).withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${caregiver.prenom.isNotEmpty ? caregiver.prenom[0] : ''}${caregiver.nom.isNotEmpty ? caregiver.nom[0] : ''}".toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF7DC4FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${caregiver.prenom} ${caregiver.nom}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_rounded,
                            size: 13,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            caregiver.telephone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      aUnPartage && statut != null
                          ? _buildStatutBadge(statut)
                          : _buildNoPartageBadge(),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Checkbox ou chevron
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 30,
                  width: 30,
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
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
