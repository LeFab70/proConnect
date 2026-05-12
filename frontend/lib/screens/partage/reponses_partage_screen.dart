import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/partage_provider.dart';
import '../../models/partage_suivi.dart';
import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';
import '../../widgets/notifications/rappels_bell_inbox_section.dart';

class ReponsesPartageScreen extends StatelessWidget {
  const ReponsesPartageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    final auth = context.watch<AuthProvider>();
    final partageProv = context.watch<PartageProvider>();
    final reponses = partageProv.getReponsesPourAine(auth);
    final caregiverProv = context.watch<CaregiverProvider>();
    final acceptees = reponses
        .where((p) => p.statut == StatutPartage.actif)
        .toList();
    final refusees = reponses
        .where((p) => p.statut != StatutPartage.actif)
        .toList();

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, reponses.length),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      children: [
                        RappelsBellInboxSection(
                          filterAineId: auth.currentUserLocalId,
                        ),
                        if (reponses.isNotEmpty) ...[
                          _buildSummaryRow(acceptees.length, refusees.length),
                          const SizedBox(height: 12),
                          ..._buildPartageListChildren(
                            context,
                            acceptees,
                            refusees,
                            caregiverProv,
                          ),
                        ] else
                          _buildPartageEmptyBelowRappels(),
                      ],
                    ),
                  ),
                ],
              ),
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
                "Réponses de partage",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (count > 0)
                Text(
                  "$count réponse(s)",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha:0.45),
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

  // ─── SUMMARY ROW ───────────────────────────────────────────────────────────

  Widget _buildSummaryRow(int acceptees, int refusees) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryChip(
              acceptees.toString(),
              "Acceptée(s)",
              Icons.check_circle_outline_rounded,
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryChip(
              refusees.toString(),
              "Refusée(s)",
              Icons.cancel_outlined,
              const Color(0xFFEF4444),
            ),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.25), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 5),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha:0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LIST ──────────────────────────────────────────────────────────────────

  List<Widget> _buildPartageListChildren(
    BuildContext context,
    List acceptees,
    List refusees,
    CaregiverProvider caregiverProv,
  ) {
    return [
      if (acceptees.isNotEmpty) ...[
        _buildSectionLabel(
          "Acceptées",
          Icons.check_circle_outline_rounded,
          const Color(0xFF10B981),
        ),
        const SizedBox(height: 10),
        ...acceptees.map(
          (p) => Dismissible(
            key: ValueKey("reponse_${p.id}"),
            direction: DismissDirection.endToStart,
            background: _buildDeleteBackground(),
            onDismissed: (_) {
              context.read<PartageProvider>().masquerNotification(p.id);
            },
            child: _buildReponseCard(p, true, caregiverProv),
          ),
        ),
      ],
      if (refusees.isNotEmpty) ...[
        if (acceptees.isNotEmpty) const SizedBox(height: 8),
        _buildSectionLabel(
          "Refusées",
          Icons.cancel_outlined,
          const Color(0xFFEF4444),
        ),
        const SizedBox(height: 10),
        ...refusees.map(
          (p) => Dismissible(
            key: ValueKey("reponse_${p.id}"),
            direction: DismissDirection.endToStart,
            background: _buildDeleteBackground(),
            onDismissed: (_) {
              context.read<PartageProvider>().masquerNotification(p.id);
            },
            child: _buildReponseCard(p, false, caregiverProv),
          ),
        ),
      ],
    ];
  }

  Widget _buildPartageEmptyBelowRappels() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        children: [
          Icon(
            Icons.share_outlined,
            size: 40,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          TrText(
            "Aucune réponse de partage pour le moment",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
  // ─── REPONSE CARD ──────────────────────────────────────────────────────────

  Widget _buildReponseCard(
    dynamic partage,
    bool isAccepted,
    CaregiverProvider caregiverProv,
  ) {
    final color = isAccepted
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    final icon = isAccepted
        ? Icons.check_circle_outline_rounded
        : Icons.cancel_outlined;

    final nomProche = _getNomProche(partage, caregiverProv);

    final titre = isAccepted ? "$nomProche a accepté" : "$nomProche a refusé";

    final sousTitre = isAccepted
        ? "$nomProche a accepté votre demande de partage."
        : "$nomProche a refusé votre demande de partage.";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:isAccepted ? 0.09 : 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha:0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha:0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
              color: color.withValues(alpha:0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha:0.3), width: 1.5),
              boxShadow: isAccepted
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha:0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 14),

          // Texte
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  sousTitre,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha:0.45),
                    height: 1.4,
                  ),
                ),

                // Relation
                if ((partage.relation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 12,
                        color: Colors.white.withValues(alpha:0.35),
                      ),

                      const SizedBox(width: 5),

                      Text(
                        partage.relation ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha:0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha:0.3), width: 1),
            ),
            child: Text(
              isAccepted ? "Actif" : "Refusé",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNomProche(dynamic partage, CaregiverProvider caregiverProv) {
    final nomDepuisPartage = partage.procheNomComplet.toString().trim();

    if (nomDepuisPartage.isNotEmpty && nomDepuisPartage != "Proche inconnu") {
      return nomDepuisPartage;
    }

    try {
      final proche = caregiverProv.caregivers.firstWhere(
        (c) => c.id == partage.procheAidantId,
      );

      final nom = "${proche.prenom} ${proche.nom}".trim();
      return nom.isNotEmpty ? nom : "Proche inconnu";
    } catch (_) {
      return "Proche inconnu";
    }
  }
}
