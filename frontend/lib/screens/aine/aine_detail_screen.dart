import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/aine.dart';

class AineDetailScreen extends StatelessWidget {
  final Aine aine;

  const AineDetailScreen({super.key, required this.aine});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final String prenom = aine.prenom;
    final String nom = aine.nom;
    final initiales =
        "${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}"
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
                          _buildAvatarHero(initiales, prenom, nom),
                          const SizedBox(height: 24),
                          _buildPersonalCard(),
                          if (aine.adresse != null) ...[
                            const SizedBox(height: 16),
                            _buildAddressCard(),
                          ],
                          const SizedBox(height: 16),
                          _buildMedicalCard(),
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

          const Text(
            "Fiche de l'aîné",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildAvatarHero(String initiales, String prenom, String nom) {
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
            child: initiales.isNotEmpty
                ? Text(
                    initiales,
                    style: const TextStyle(
                      color: Color(0xFF7DC4FF),
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: 1,
                    ),
                  )
                : Icon(
                    Icons.elderly_rounded,
                    size: 36,
                    color: const Color(0xFF7DC4FF).withValues(alpha: 0.7),
                  ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          "$prenom $nom".trim(),
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
            color: const Color(0xFF7DC4FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF7DC4FF).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.elderly_rounded,
                size: 13,
                color: const Color(0xFF7DC4FF).withValues(alpha: 0.8),
              ),
              const SizedBox(width: 5),
              Text(
                "Aîné suivi",
                style: TextStyle(
                  color: const Color(0xFF7DC4FF).withValues(alpha: 0.9),
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

  Widget _buildPersonalCard() {
    return _buildGlassCard(
      sectionIcon: Icons.person_outline_rounded,
      sectionTitle: "Informations personnelles",
      children: [
        _buildInfoRow(
          Icons.cake_rounded,
          "Date de naissance",
          DateFormat('dd MMMM yyyy', 'fr').format(aine.dateNaissance),
        ),
        _buildDivider(),
        _buildInfoRow(Icons.phone_rounded, "Téléphone", aine.telephone),
        _buildDivider(),
        _buildInfoRow(Icons.alternate_email_rounded, "Email", aine.email),
      ],
    );
  }

  Widget _buildAddressCard() {
    final adresse = aine.adresse!;

    return _buildGlassCard(
      sectionIcon: Icons.location_on_outlined,
      sectionTitle: "Adresse",
      children: [
        if ((adresse.numero ?? '').trim().isNotEmpty) ...[
          _buildInfoRow(Icons.numbers_rounded, "No.", adresse.numero!.trim()),
          _buildDivider(),
        ],
        _buildInfoRow(Icons.signpost_outlined, "Rue", adresse.rue ?? ''),
        _buildDivider(),
        _buildInfoRow(
          Icons.location_city_rounded,
          "Ville",
          adresse.ville ?? '',
        ),
        if ((adresse.codePostal ?? '').isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(
            Icons.markunread_mailbox_outlined,
            "Code postal",
            adresse.codePostal ?? '',
          ),
        ],
        if ((adresse.province ?? '').trim().isNotEmpty) ...[
          _buildDivider(),
          _buildInfoRow(
            Icons.flag_outlined,
            "Province",
            adresse.province!.trim(),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicalCard() {
    return _buildGlassCard(
      sectionIcon: Icons.local_hospital_outlined,
      sectionTitle: "Informations médicales",
      children: [
        _buildInfoRow(
          Icons.person_search_rounded,
          "Médecin traitant",
          aine.docteur,
        ),
        _buildDivider(),
        _buildInfoRow(
          Icons.phone_in_talk_rounded,
          "Contact médecin",
          aine.numeroDocteur,
        ),
      ],
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
              Text(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
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
