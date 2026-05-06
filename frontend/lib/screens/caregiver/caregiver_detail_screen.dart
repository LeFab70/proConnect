import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/caregiver.dart';
import '../../models/partage_suivi.dart';
import '../../provider/auth_provider.dart';
import '../../provider/partage_provider.dart';
import 'add_caregiver_screen.dart';
import '../../widgets/tr_text.dart';

class CaregiverDetailScreen extends StatelessWidget {
  final Caregiver caregiver;

  const CaregiverDetailScreen({super.key, required this.caregiver});

  PartageSuivi? _getPartageExistant({
    required PartageProvider partageProvider,
    required int aineId,
    required int procheId,
  }) {
    for (final partage in partageProvider.partages) {
      if (partage.aineId == aineId && partage.procheAidantId == procheId) {
        return partage;
      }
    }
    return null;
  }

  Future<bool> _confirmCancel(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const TrText(
          "Annuler le partage",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TrText(
          "Voulez-vous vraiment annuler ce partage ? Le proche n'aura plus accès à votre suivi.",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: TrText(
              "Non",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const TrText(
              "Oui, annuler",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
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

    final auth = context.watch<AuthProvider>();
    final partageProvider = context.watch<PartageProvider>();
    final aineId = auth.currentUserLocalId ?? 0;

    final partageExistant = _getPartageExistant(
      partageProvider: partageProvider,
      aineId: aineId,
      procheId: caregiver.id,
    );
    final bool partageExiste = partageExistant != null;

    final initiales =
        "${caregiver.prenom.isNotEmpty ? caregiver.prenom[0] : ''}${caregiver.nom.isNotEmpty ? caregiver.nom[0] : ''}"
            .toUpperCase();

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
                      const Color(0xFF004E92).withValues(alpha: 0.5),
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
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      child: Column(
                        children: [
                          _buildAvatarHero(
                            initiales,
                            partageExiste,
                            partageExistant,
                          ),
                          const SizedBox(height: 24),
                          _buildInfoCard(),
                          if (caregiver.adresse != null) ...[
                            const SizedBox(height: 16),
                            _buildAddressCard(),
                          ],
                          if (auth.isAine) ...[
                            const SizedBox(height: 24),
                            _buildActionsCard(
                              context,
                              partageExiste,
                              partageExistant,
                              partageProvider,
                              auth,
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
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

          const TrText(
            "Détails du proche",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCaregiverScreen(caregiver: caregiver),
                ),
              );
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
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarHero(
    String initiales,
    bool partageExiste,
    PartageSuivi? partageExistant,
  ) {
    Color statutColor;
    String statutLabel;
    IconData statutIcon;

    if (!partageExiste) {
      statutColor = Colors.white.withValues(alpha: 0.3);
      statutLabel = "Non partagé";
      statutIcon = Icons.link_off_rounded;
    } else {
      switch (partageExistant!.statut) {
        case StatutPartage.actif:
          statutColor = const Color(0xFF10B981);
          statutLabel = "Lien établi";
          statutIcon = Icons.check_circle_outline_rounded;
          break;
        case StatutPartage.enAttente:
          statutColor = const Color(0xFFF59E0B);
          statutLabel = "En attente";
          statutIcon = Icons.schedule_rounded;
          break;
        case StatutPartage.refuse:
          statutColor = const Color(0xFFEF4444);
          statutLabel = "Refusé";
          statutIcon = Icons.cancel_outlined;
          break;
      }
    }

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF004E92).withValues(alpha: 0.5),
            border: Border.all(
              color: const Color(0xFF4A9FE8).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004E92).withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: TrText(
              initiales,
              style: const TextStyle(
                color: Color(0xFF7DC4FF),
                fontWeight: FontWeight.w900,
                fontSize: 28,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        TrText(
          "${caregiver.prenom ?? ''} ${caregiver.nom ?? ''}".trim(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: statutColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statutColor.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statutIcon, size: 13, color: statutColor),
              const SizedBox(width: 5),
              TrText(
                statutLabel,
                style: TextStyle(
                  color: statutColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return _buildGlassCard(
      sectionIcon: Icons.person_outline_rounded,
      sectionTitle: "Informations personnelles",
      children: [
        _buildInfoRow(
          Icons.phone_rounded,
          "Téléphone",
          caregiver.telephone ?? '',
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.alternate_email_rounded,
          "Email",
          caregiver.email ?? '',
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    final adresse = caregiver.adresse!;

    return _buildGlassCard(
      sectionIcon: Icons.location_on_outlined,
      sectionTitle: "Adresse",
      children: [
        if ((adresse.numero ?? '').trim().isNotEmpty)
          _buildInfoRow(
            Icons.numbers_rounded,
            "No.",
            adresse.numero!.trim(),
          ),
        if ((adresse.numero ?? '').trim().isNotEmpty) _buildDivider(),
        _buildInfoRow(Icons.signpost_outlined, "Rue", adresse.rue ?? ''),
        _buildDivider(),
        _buildInfoRow(
          Icons.location_city_rounded,
          "Ville",
          adresse.ville ?? '',
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.markunread_mailbox_outlined,
          "Code postal",
          adresse.codePostal ?? '',
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.flag_outlined,
          "Province",
          adresse.province ?? '',
        ),
      ],
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    bool partageExiste,
    PartageSuivi? partageExistant,
    PartageProvider partageProvider,
    AuthProvider auth,
  ) {
    return _buildGlassCard(
      sectionIcon: Icons.share_outlined,
      sectionTitle: "Partage du suivi",
      children: [
        _buildActionButton(
          onTap: partageExiste
              ? null
              : () => Navigator.pushNamed(
                  context,
                  '/partageAine',
                  arguments: caregiver,
                ),
          gradient: partageExiste
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          solidColor: partageExiste ? Colors.white.withValues(alpha: 0.06) : null,
          icon: partageExiste
              ? Icons.lock_outline_rounded
              : Icons.share_rounded,
          iconColor: partageExiste
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white,
          label: partageExiste ? "Suivi déjà partagé" : "Partager mon suivi",
          labelColor: partageExiste
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white,
          borderColor: partageExiste ? Colors.white.withValues(alpha: 0.08) : null,
          hasShadow: !partageExiste,
        ),

        if (partageExiste) ...[
          const SizedBox(height: 12),
          _buildActionButton(
            onTap: () async {
              final confirmed = await _confirmCancel(context);
              if (!confirmed) return;
              await partageProvider.supprimerPartage(
                partageExistant!.id,
                auth,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const TrText(
                      "Partage annulé",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.all(24),
                  ),
                );
              }
            },
            solidColor: const Color(0xFFEF4444).withValues(alpha: 0.12),
            borderColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
            icon: Icons.link_off_rounded,
            iconColor: const Color(0xFFFF7070),
            label: "Annuler le partage",
            labelColor: const Color(0xFFFF7070),
            hasShadow: false,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    Gradient? gradient,
    Color? solidColor,
    Color? borderColor,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    bool hasShadow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? solidColor : null,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1)
              : null,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: const Color(0xFF004E92).withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            TrText(
              label,
              style: TextStyle(
                color: labelColor,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required IconData sectionIcon,
    required String sectionTitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  sectionIcon,
                  color: const Color(0xFF7DC4FF),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              TrText(
                sectionTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.35)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TrText(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              TrText(
                value.isEmpty ? "—" : value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: value.isEmpty
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 18,
      indent: 29,
    );
  }
}
