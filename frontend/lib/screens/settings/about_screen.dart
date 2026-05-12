import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _version = '1.0.0';
  static const String _build = '2026.04';
  static const String _privacyUrl = 'https://proconnectnb.ca/confidentialite';
  static const String _termsUrl = 'https://proconnectnb.ca/conditions';

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildLegalCard(context),
                        const SizedBox(height: 16),
                        _buildTeamCard(),
                        const SizedBox(height: 28),
                        _buildFooter(),
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
            'À propos',
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

  // ─── HERO ──────────────────────────────────────────────────────────────────

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004E92).withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),

          const SizedBox(height: 16),

          const TrText(
            'ProConnect NB',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Text(
              'Version $_version  ·  Build $_build',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7DC4FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7DC4FF).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: const TrText(
              'Santé & bien-être · Nouveau-Brunswick',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF7DC4FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'ProConnect NB est une application de santé numérique conçue pour aider les aînés et leurs proches aidants à gérer médicaments, activités physiques et rendez-vous médicaux en toute simplicité.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── INFO CARD ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    final infos = [
      ('Version', _version),
      ('Build', _build),
      ('Plateforme', 'Android & iOS'),
      ('Développé par', 'Équipe ProConnect NB'),
      ('Région', 'Nouveau-Brunswick, Canada'),
    ];

    return _buildGlassCard(
      sectionIcon: Icons.info_outline_rounded,
      sectionTitle: 'Informations',
      children: infos.asMap().entries.map((e) {
        final isLast = e.key == infos.length - 1;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Row(
                children: [
                  Expanded(
                    child: TrText(
                      e.value.$1,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.45),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    e.value.$2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          ],
        );
      }).toList(),
    );
  }

  // ─── LEGAL CARD ────────────────────────────────────────────────────────────

  Widget _buildLegalCard(BuildContext context) {
    return _buildGlassCard(
      sectionIcon: Icons.gavel_rounded,
      sectionTitle: 'Légal',
      children: [
        _buildLinkTile(
          icon: Icons.privacy_tip_outlined,
          label: 'Politique de confidentialité',
          color: const Color(0xFF7DC4FF),
          onTap: () => _launch(_privacyUrl),
        ),
        _buildCardDivider(),
        _buildLinkTile(
          icon: Icons.gavel_rounded,
          label: 'Conditions d\'utilisation',
          color: const Color(0xFFA78BFA),
          onTap: () => _launch(_termsUrl),
        ),
        _buildCardDivider(),
        _buildLinkTile(
          icon: Icons.history_edu_rounded,
          label: 'Licences open source',
          color: const Color(0xFF34D399),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'ProConnect NB',
            applicationVersion: _version,
          ),
        ),
      ],
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: Colors.white.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TrText(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TEAM CARD ─────────────────────────────────────────────────────────────

  Widget _buildTeamCard() {
    final members = [
      (
        'GA',
        'Grace Akissi',
        'Développeur Intégration Frontend (API & State Management)',
      ),
      ('PN', 'Pérez Nguefack', 'Développeur Frontend UI/UX'),
      ('FK', 'Fabrice Kouonang', 'Développeur Backend (Logique Métier & API)'),
      ('KA', 'Kayleb Aubie-Boudreau', 'Ingénieur Cloud & DevOps (Azure)'),
    ];

    // Couleurs distinctes par membre
    final colors = [
      const Color(0xFF7DC4FF),
      const Color(0xFF34D399),
      const Color(0xFFA78BFA),
      const Color(0xFFFBBF24),
    ];

    return _buildGlassCard(
      sectionIcon: Icons.people_outline_rounded,
      sectionTitle: 'Équipe',
      children: members.asMap().entries.map((e) {
        final isLast = e.key == members.length - 1;
        final color = colors[e.key % colors.length];
        final (initials, name, role) = e.value;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: color,
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
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.4),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                color: Colors.white.withValues(alpha: 0.06),
                height: 1,
                indent: 56,
              ),
          ],
        );
      }).toList(),
    );
  }

  // ─── FOOTER ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 ProConnect NB · Tous droits réservés',
        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.25)),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─── GLASS CARD ────────────────────────────────────────────────────────────

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

  Widget _buildCardDivider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 1,
      indent: 50,
    );
  }
}
