import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/partage_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/aine_provider.dart';
import '../../widgets/tr_text.dart';

class DemandesRecuesScreen extends StatelessWidget {
  const DemandesRecuesScreen({super.key});

  String _getNomAine(dynamic demande, AineProvider aineProv) {
    final nomDepuisPartage = demande.aineNomComplet.toString().trim();

    if (nomDepuisPartage.isNotEmpty && nomDepuisPartage != "Aîné inconnu") {
      return nomDepuisPartage;
    }

    try {
      final aine = aineProv.aines.firstWhere((a) => a.id == demande.aineId);
      final nom = "${aine.prenom} ${aine.nom}".trim();
      return nom.isNotEmpty ? nom : "Aîné inconnu";
    } catch (_) {
      return "Aîné inconnu";
    }
  }

  String _getInitiales(String nom) {
    final parts = nom.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final partageProv = context.watch<PartageProvider>();
    final auth = context.watch<AuthProvider>();
    final aineProv = context.watch<AineProvider>();

    final demandes = partageProv.getDemandesPourProche(auth);

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
                      const Color(0xFF004E92).withValues(alpha:0.5),
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
                      Colors.white.withValues(alpha:0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, demandes.length),
                  Expanded(
                    child: demandes.isEmpty
                        ? _buildEmptyState()
                        : _buildList(
                            context,
                            demandes,
                            partageProv,
                            auth,
                            aineProv,
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

  Widget _buildHeader(BuildContext context, int count) {
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
                color: Colors.white.withValues(alpha:0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha:0.15),
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
                "Demandes reçues",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (count > 0)
                Text(
                  "$count demande(s) en attente",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFF59E0B).withValues(alpha:0.85),
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
              color: Colors.white.withValues(alpha:0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha:0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: Colors.white.withValues(alpha:0.3),
            ),
          ),
          const SizedBox(height: 20),
          TrText(
            "Aucune demande en attente",
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les nouvelles demandes apparaîtront ici",
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─── LIST ──────────────────────────────────────────────────────────────────

  Widget _buildList(
    BuildContext context,
    List demandes,
    PartageProvider partageProv,
    AuthProvider auth,
    AineProvider aineProv,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      itemCount: demandes.length,
      itemBuilder: (ctx, index) {
        final demande = demandes[index];
        final nomAine = _getNomAine(demande, aineProv);
        final initiales = _getInitiales(nomAine);

        return _buildDemandeCard(
          context: context,
          demande: demande,
          nomAine: nomAine,
          initiales: initiales,
          partageProv: partageProv,
          auth: auth,
        );
      },
    );
  }

  // ─── DEMANDE CARD ──────────────────────────────────────────────────────────

  Widget _buildDemandeCard({
    required BuildContext context,
    required dynamic demande,
    required String nomAine,
    required String initiales,
    required PartageProvider partageProv,
    required AuthProvider auth,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha:0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne identité ──
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha:0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha:0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initiales,
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
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
                    Text(
                      nomAine,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Souhaite partager son suivi",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha:0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge "En attente"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha:0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha:0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 11,
                      color: const Color(0xFFF59E0B).withValues(alpha:0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "En attente",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B).withValues(alpha:0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha:0.07), height: 1),
          const SizedBox(height: 12),

          // ── Relation ──
          Row(
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 14,
                color: Colors.white.withValues(alpha:0.35),
              ),
              const SizedBox(width: 8),
              Text(
                "Relation : ",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha:0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                demande.relation ?? 'Non précisée',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Boutons ──
          Row(
            children: [
              // Refuser
              Expanded(
                child: GestureDetector(
                  onTap: partageProv.isLoading
                      ? null
                      : () async {
                          final ok = await partageProv.refuserDemande(
                            demande.id,
                            auth,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? "Demande de $nomAine refusée"
                                    : partageProv.error,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: ok
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.all(24),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha:0.12),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        partageProv.isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white.withValues(alpha:0.5),
                              ),
                        const SizedBox(width: 6),
                        TrText(
                          "Refuser",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.55),
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Accepter
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: partageProv.isLoading
                      ? null
                      : () async {
                          final ok = await partageProv.accepterDemande(
                            demande.id,
                            auth,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? "Demande de $nomAine acceptée"
                                    : partageProv.error,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: ok
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.all(24),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34D399), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha:0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        partageProv.isLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                        const SizedBox(width: 6),
                        const TrText(
                          "Accepter",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
