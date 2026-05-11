import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/tr_text.dart';
import '../../provider/auth_provider.dart';
import '../../provider/settings_provider.dart';
import '../auth/post_logout_transition_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

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
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                      children: [
                        // ── COMPTE ──────────────────────────────
                        _buildSectionHeader('Compte'),
                        _buildGlassCard(
                          children: [
                            _buildNavItem(
                              context,
                              icon: Icons.person_outline_rounded,
                              labelKey: 'Éditer le profil',
                              onTap: () =>
                                  Navigator.pushNamed(context, '/editprofil'),
                            ),
                            _buildCardDivider(),
                            _buildNavItem(
                              context,
                              icon: Icons.lock_outline_rounded,
                              labelKey: 'Changer le mot de passe',
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/settings/password',
                              ),
                            ),
                          ],
                        ),

                        // ── PRÉFÉRENCES ──────────────────────────
                        _buildSectionHeader('Préférences'),
                        _buildGlassCard(
                          children: [
                            _buildNavItem(
                              context,
                              icon: Icons.language_rounded,
                              labelKey: 'Langue',
                              trailingText: settings.language == AppLanguage.fr
                                  ? 'Français'
                                  : 'English',
                              onTap: () =>
                                  _showLanguageDialog(context, settings),
                            ),
                            _buildCardDivider(),
                            _buildToggleItem(
                              context,
                              icon: Icons.dark_mode_outlined,
                              labelKey: 'Mode sombre',
                              subtitleKey: settings.isDarkMode
                                  ? 'Activé'
                                  : 'Désactivé',
                              value: settings.isDarkMode,
                              onChanged: (_) => settings.toggleTheme(),
                            ),
                            _buildCardDivider(),
                            _FontSizeItem(settings: settings),
                            _buildCardDivider(),
                            _buildNavItem(
                              context,
                              icon: Icons.notifications_none_rounded,
                              labelKey: 'Notifications',
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/settings/notifications',
                              ),
                            ),
                          ],
                        ),

                        // ── SUPPORT ──────────────────────────────
                        _buildSectionHeader('Support'),
                        _buildGlassCard(
                          children: [
                            _buildNavItem(
                              context,
                              icon: Icons.help_outline_rounded,
                              labelKey: 'Aide & Support',
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/settings/help',
                              ),
                            ),
                            _buildCardDivider(),
                            _buildNavItem(
                              context,
                              icon: Icons.info_outline_rounded,
                              labelKey: 'À propos',
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/settings/about',
                              ),
                            ),
                          ],
                        ),

                        // ── DÉCONNEXION ───────────────────────────
                        const SizedBox(height: 24),
                        _buildLogoutButton(context, auth),
                        const SizedBox(height: 16),
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
            'Paramètres',
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

  // ─── SECTION HEADER ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String titleKey) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: TrText(
        titleKey,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  // ─── GLASS CARD ────────────────────────────────────────────────────────────

  Widget _buildGlassCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildCardDivider() {
    return Divider(
      height: 0,
      indent: 56,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.07),
    );
  }

  // ─── ICÔNE BOX ─────────────────────────────────────────────────────────────

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Icon(icon, color: const Color(0xFF7DC4FF), size: 17),
    );
  }

  // ─── NAV ITEM ──────────────────────────────────────────────────────────────

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String labelKey,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.03),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _buildIconBox(icon),
            const SizedBox(width: 14),
            Expanded(
              child: TrText(
                labelKey,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
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

  // ─── TOGGLE ITEM ───────────────────────────────────────────────────────────

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required String labelKey,
    required String subtitleKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconBox(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  labelKey,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                TrText(
                  subtitleKey,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF004E92),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT ────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context, AuthProvider auth) {
    return GestureDetector(
      onTap: () => _confirmLogout(context, auth),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: Color(0xFFFF7070),
              size: 19,
            ),
            const SizedBox(width: 10),
            TrText(
              'Se déconnecter',
              style: const TextStyle(
                color: Color(0xFFFF7070),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOGS ───────────────────────────────────────────────────────────────

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: TrText(
          'Choisir la langue',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLangTile(
              context,
              flag: '🇫🇷',
              label: 'Français',
              isActive: settings.language == AppLanguage.fr,
              onTap: () {
                settings.setLanguage(AppLanguage.fr);
                Navigator.pop(ctx);
              },
            ),
            Divider(color: Colors.white.withValues(alpha: 0.07), height: 8),
            _buildLangTile(
              context,
              flag: '🇬🇧',
              label: 'English',
              isActive: settings.language == AppLanguage.en,
              onTap: () {
                settings.setLanguage(AppLanguage.en);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTile(
    BuildContext context, {
    required String flag,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 15,
                ),
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF7DC4FF),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: TrText(
          'Se déconnecter',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TrText(
          'Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: TrText(
              'Annuler',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: TrText(
              'Déconnecter',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final raw = auth.firstName?.trim();
      final firstName =
          (raw == null || raw.isEmpty) ? null : raw;
      await auth.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
            builder: (_) =>
                PostLogoutTransitionScreen(firstName: firstName),
          ),
          (_) => false,
        );
      }
    }
  }
}

// ─── FONT SIZE ITEM ──────────────────────────────────────────────────────────

class _FontSizeItem extends StatelessWidget {
  final SettingsProvider settings;
  const _FontSizeItem({required this.settings});

  String get _label {
    final v = settings.fontSize;
    if (v <= 0.85) return 'Très petite';
    if (v <= 0.95) return 'Petite';
    if (v <= 1.05) return 'Normale';
    if (v <= 1.15) return 'Grande';
    if (v <= 1.25) return 'Très grande';
    return 'Maximale';
  }

  Widget _buildIconBox() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF004E92).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF4A9FE8).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.format_size_rounded,
        color: Color(0xFF7DC4FF),
        size: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBox(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      'Taille du texte',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    TrText(
                      _label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${settings.fontSize.toStringAsFixed(1)}×',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7DC4FF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4A9FE8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: Colors.white,
              overlayColor: const Color(0x1A4A9FE8),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              min: 0.8,
              max: 1.5,
              divisions: 7,
              value: settings.fontSize,
              onChanged: (v) => settings.setFontSize(v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                Text(
                  'A',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
