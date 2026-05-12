import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/partage_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/aine_provider.dart';
import '../../widgets/tr_text.dart';
import '../../widgets/notifications/rappels_bell_inbox_section.dart';

class DemandesRecuesScreen extends StatefulWidget {
  const DemandesRecuesScreen({super.key});

  @override
  State<DemandesRecuesScreen> createState() => _DemandesRecuesScreenState();
}

class _DemandesRecuesScreenState extends State<DemandesRecuesScreen> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_hasLoaded) return;
    _hasLoaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final auth = context.read<AuthProvider>();
      final aineProv = context.read<AineProvider>();
      final partageProv = context.read<PartageProvider>();

      if (auth.token == null) return;

      await partageProv.fetchPartages(auth);

      if (auth.isAidant && aineProv.aines.isEmpty) {
        await aineProv.fetchAines(auth);
      }
    });
  }

  String _getNomAine(dynamic demande, AineProvider aineProv) {
    
    final prenom = (demande.ainePrenom ?? '').toString().trim();
    final nom = (demande.aineNom ?? '').toString().trim();

    final nomComplet = '$prenom $nom'.trim();

    if (nomComplet.isNotEmpty) {
      return nomComplet;
    }

    try {
      final aine = aineProv.aines.firstWhere((a) => a.id == demande.aineId);

      final nomDepuisListe = '${aine.prenom} ${aine.nom}'.trim();

      if (nomDepuisListe.isNotEmpty) {
        return nomDepuisListe;
      }
    } catch (_) {}

    return 'Aîné inconnu';
  }

  String _getInitiales(String nom) {
    final parts = nom.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    if (parts.isNotEmpty && parts[0].isNotEmpty) {
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
                  _buildHeader(context, demandes.length),
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                          sliver: SliverToBoxAdapter(
                            child: RappelsBellInboxSection(
                              filterAineId: aineProv.selectedAine?.id,
                            ),
                          ),
                        ),
                        if (demandes.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: _buildEmptyState()),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                ctx,
                                index,
                              ) {
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
                              }, childCount: demandes.length),
                            ),
                          ),
                      ],
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
                "Demandes reçues",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              if (count > 0)
                Text(
                  "$count demande(s) en attente",
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.85),
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

  Widget _buildEmptyState() {
    return Center(
      child: TrText(
        "Aucune demande en attente",
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

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
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(
                  0xFFF59E0B,
                ).withValues(alpha: 0.15),
                child: Text(
                  initiales,
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.w800,
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
                    Text(
                      "Souhaite partager son suivi",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: partageProv.isLoading
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
                              ),
                            ),
                          );
                        },
                  child: const TrText(
                    "Refuser",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  onPressed: partageProv.isLoading
                      ? null
                      : () async {
                          final ok = await partageProv.accepterDemande(
                            demande.id,
                            auth,
                          );

                          if (!context.mounted) return;

                          if (ok) {
                            await context.read<AineProvider>().fetchAines(auth);
                          }

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? "Demande de $nomAine acceptée"
                                    : partageProv.error,
                              ),
                            ),
                          );
                        },
                  child: const TrText(
                    "Accepter",
                    style: TextStyle(color: Colors.white),
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
