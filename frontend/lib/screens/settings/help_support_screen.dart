import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaq;

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'Comment ajouter un médicament ?',
      answer:
          'Rendez-vous dans l\'onglet "Médicaments" depuis le menu ou le tableau de bord, puis appuyez sur le bouton "+" en bas à droite pour ajouter un nouveau médicament avec son nom, dosage et horaire.',
    ),
    _FaqItem(
      question: 'Comment inviter un proche aidant ?',
      answer:
          'Dans l\'onglet "Proche aidant", appuyez sur "Inviter" et saisissez l\'adresse courriel de la personne. Elle recevra un lien pour créer son compte et accéder à votre profil de santé partagé.',
    ),
    _FaqItem(
      question: 'Mes données sont-elles sécurisées ?',
      answer:
          'Oui, toutes vos données sont chiffrées en transit (TLS) et au repos. Nous ne partageons jamais vos informations personnelles avec des tiers sans votre consentement explicite.',
    ),
    _FaqItem(
      question: 'Comment modifier un rendez-vous ?',
      answer:
          'Dans l\'onglet "Rendez-vous", appuyez sur le rendez-vous souhaité pour voir ses détails, puis utilisez l\'icône de crayon pour le modifier ou l\'icône de corbeille pour le supprimer.',
    ),
    _FaqItem(
      question: 'Je ne reçois pas mes rappels de médicaments.',
      answer:
          'Vérifiez que les notifications sont activées dans Paramètres → Notifications. Assurez-vous également que l\'application n\'est pas en mode silencieux ou que la batterie n\'est pas en mode économie extrême qui bloque les notifications en arrière-plan.',
    ),
    _FaqItem(
      question: 'Comment supprimer mon compte ?',
      answer:
          'Pour supprimer votre compte et toutes vos données, contactez notre support à support@proconnectnb.ca avec l\'objet "Suppression de compte". Votre demande sera traitée dans les 72 heures.',
    ),
  ];

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
                        _buildContactCard(),
                        const SizedBox(height: 16),
                        _buildFaqCard(),
                        const SizedBox(height: 16),
                        _buildReportButton(),
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
            'Aide & Support',
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF004E92).withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004E92).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF7DC4FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TrText(
                  'Comment pouvons-nous vous aider ?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consultez la FAQ ou contactez-nous directement.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CONTACT CARD ──────────────────────────────────────────────────────────

  Widget _buildContactCard() {
    return _buildGlassCard(
      sectionIcon: Icons.contact_support_outlined,
      sectionTitle: 'Nous contacter',
      children: [
        _buildContactTile(
          icon: Icons.email_outlined,
          label: 'Courriel',
          value: 'support@proconnectnb.ca',
          color: const Color(0xFF7DC4FF),
          onTap: () => _launch('mailto:support@proconnectnb.ca'),
        ),
        _buildCardDivider(),
        _buildContactTile(
          icon: Icons.phone_outlined,
          label: 'Téléphone',
          value: '+1 (506) 000-0000',
          color: const Color(0xFF34D399),
          onTap: () => _launch('tel:+15060000000'),
        ),
        _buildCardDivider(),
        _buildContactTile(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Chat en ligne',
          value: 'Disponible 9h – 17h (HNA)',
          color: const Color(0xFFA78BFA),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: Colors.white.withValues(alpha: 0.04),
      highlightColor: Colors.white.withValues(alpha: 0.02),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrText(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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

  // ─── FAQ CARD ──────────────────────────────────────────────────────────────

  Widget _buildFaqCard() {
    return _buildGlassCard(
      sectionIcon: Icons.quiz_outlined,
      sectionTitle: 'Questions fréquentes',
      children: [
        ..._faqs.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isOpen = _expandedFaq == i;
          final isLast = i == _faqs.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => setState(() => _expandedFaq = isOpen ? null : i),
                borderRadius: BorderRadius.circular(12),
                splashColor: Colors.white.withValues(alpha: 0.04),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: isOpen
                                  ? const Color(0xFF7DC4FF)
                                  : Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: TrText(
                              item.question,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isOpen
                                    ? const Color(0xFF7DC4FF)
                                    : Colors.white.withValues(alpha: 0.85),
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isOpen
                                  ? const Color(0xFF7DC4FF)
                                  : Colors.white.withValues(alpha: 0.3),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004E92).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFF4A9FE8).withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.answer,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            ],
          );
        }),
      ],
    );
  }

  // ─── REPORT BUTTON ─────────────────────────────────────────────────────────

  Widget _buildReportButton() {
    return GestureDetector(
      onTap: () => _launch(
        'mailto:support@proconnectnb.ca?subject=Signalement%20d%27un%20problème',
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report_outlined,
              color: const Color(0xFFFF7070).withValues(alpha: 0.8),
              size: 19,
            ),
            const SizedBox(width: 8),
            TrText(
              'Signaler un problème',
              style: TextStyle(
                color: const Color(0xFFFF7070).withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
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
      indent: 52,
    );
  }
}

// ── Modèle ─────────────────────────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
