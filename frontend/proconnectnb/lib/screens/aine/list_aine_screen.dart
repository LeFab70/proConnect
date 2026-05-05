import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/aine_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/partage_provider.dart';
import '../../models/partage_suivi.dart';
import 'aine_detail_screen.dart';
import '../../widgets/tr_text.dart';

class ListAineScreen extends StatefulWidget {
  const ListAineScreen({super.key});

  @override
  State<ListAineScreen> createState() => _ListAineScreenState();
}

class _ListAineScreenState extends State<ListAineScreen> {
  final Set<int> _selectedIds = {};

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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
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
        title: const TrText(
          "Retirer un aîné",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TrText(
          count == 1
              ? "Retirer cet aîné de votre liste ?"
              : "Retirer les $count aînés sélectionnés ?",
          style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TrText(
              "Annuler",
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
            ),
            child: const TrText(
              "Retirer",
              style: TextStyle(color: Colors.white),
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

    final aineProvider = context.watch<AineProvider>();
    final partageProv = context.watch<PartageProvider>();
    final auth = context.watch<AuthProvider>();

    final currentId = auth.currentUserLocalId ?? 0;
    final mesPartages = partageProv.getTousPartagesParProche(currentId);

    final listAffichage = mesPartages
        .map((partage) {
          final aines = aineProvider.aines
              .where((a) => a.id == partage.aineId)
              .toList();

          if (aines.isEmpty) return null;

          return {
            'aine': aines.first,
            'statut': partage.statut,
            'partageId': partage.id,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();

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
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, aineProvider, partageProv, hasSelection),
              Expanded(
                child: _buildBody(
                  context,
                  aineProvider,
                  listAffichage,
                  partageProv,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AineProvider aineProvider,
    PartageProvider partageProv,
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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
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
              TrText(
                hasSelection
                    ? "${_selectedIds.length} sélectionné(s)"
                    : "Mes Aînés",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (!hasSelection)
                TrText(
                  "${aineProvider.aines.length} aîné(s) suivi(s)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
            ],
          ),
          hasSelection
              ? GestureDetector(
                  onTap: () async {
                    final confirmed = await _confirmDelete(
                      context,
                      _selectedIds.length,
                    );

                    if (!confirmed) return;

                    final ids = List<int>.from(_selectedIds);

                    for (final id in ids) {
                      await partageProv.supprimerPartage(id);
                    }

                    if (mounted) {
                      setState(() => _selectedIds.clear());
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      shape: BoxShape.circle,
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
    BuildContext context,
    AineProvider aineProvider,
    List<Map<String, dynamic>> listAffichage,
    PartageProvider partageProv,
  ) {
    if (aineProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white.withOpacity(0.6),
          strokeWidth: 2,
        ),
      );
    }

    if (listAffichage.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.elderly_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun aîné partagé",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TrText(
              "Vous n'avez pas encore de suivi partagé",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: listAffichage.length,
      itemBuilder: (context, index) {
        final item = listAffichage[index];

        final aine = item['aine'];
        final statut = item['statut'] as StatutPartage;
        final partageId = item['partageId'] as int;

        final isSelected = _selectedIds.contains(partageId);
        final isCurrent = aineProvider.selectedAine?.id == aine.id;

        final String prenom = aine.prenom ?? '';
        final String nom = aine.nom ?? '';
        final String telephone = aine.telephone ?? '';

        final initiales =
            "${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}"
                .toUpperCase();

        return GestureDetector(
          onTap: () async {
            if (_selectedIds.isNotEmpty) {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(partageId);
                } else {
                  _selectedIds.add(partageId);
                }
              });
            } else {
              if (statut != StatutPartage.actif) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: TrText(
                      "Ce lien n'est pas encore actif. Impossible de sélectionner cet aîné.",
                    ),
                  ),
                );
                return;
              }

              await context.read<AineProvider>().selectAine(aine);

              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
          onLongPress: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(partageId);
              } else {
                _selectedIds.add(partageId);
              }
            });
          },
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AineDetailScreen(aine: aine)),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFF10B981).withOpacity(0.22)
                  : isSelected
                  ? Colors.white.withOpacity(0.16)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFF10B981)
                    : isSelected
                    ? Colors.white.withOpacity(0.55)
                    : Colors.white.withOpacity(0.11),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004E92).withOpacity(0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: TrText(
                      initiales,
                      style: const TextStyle(
                        color: Color(0xFF7DC4FF),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrText(
                        "$prenom $nom".trim(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (telephone.isNotEmpty)
                        TrText(
                          telephone,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildStatutBadge(statut),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (isCurrent)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 28,
                  )
                else
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
                            : Colors.white.withOpacity(0.22),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: Colors.white.withOpacity(0.3),
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
