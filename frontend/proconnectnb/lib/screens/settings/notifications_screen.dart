import 'package:flutter/material.dart';

import '../../widgets/tr_text.dart';
import '../../provider/settings_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // États locaux des notifications (à persister via SettingsProvider si besoin)
  bool _pushEnabled       = true;
  bool _medications       = true;
  bool _activities        = true;
  bool _appointments      = true;
  bool _caregiverAlerts   = true;
  bool _weeklyReport      = false;
  bool _emailEnabled      = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF405667),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const TrText(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 4),

          // ── Maître : push ─────────────────────────────────
          _Card(children: [
            _SwitchTile(
              icon: Icons.notifications_rounded,
              iconColor: const Color(0xFF3F8CFF),
              iconBg: const Color(0xFFE3F0FF),
              label: 'Notifications push',
              subtitle: 'Activer toutes les notifications',
              value: _pushEnabled,
              onChanged: (v) => setState(() {
                _pushEnabled = v;
                if (!v) {
                  _medications     = false;
                  _activities      = false;
                  _appointments    = false;
                  _caregiverAlerts = false;
                  _weeklyReport    = false;
                }
              }),
            ),
          ]),
          const SizedBox(height: 8),

          // ── Son & vibration (depuis SettingsProvider) ─────
          _SectionLabel('Son & vibration'),
          _Card(children: [
            _SwitchTile(
              icon: Icons.volume_up_rounded,
              iconColor: const Color(0xFFE65100),
              iconBg: const Color(0xFFFFF3E0),
              label: 'Son',
              subtitle: 'Jouer un son à chaque notification',
              value: settings.sound,
              onChanged: (_) => settings.toggleSound(),
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.vibration_rounded,
              iconColor: const Color(0xFF6C5DD3),
              iconBg: const Color(0xFFEEEDFE),
              label: 'Vibration',
              subtitle: 'Vibrer à chaque notification',
              value: settings.vibration,
              onChanged: (_) => settings.toggleVibration(),
            ),
          ]),
          const SizedBox(height: 8),

          // ── Rappels ───────────────────────────────────────
          _SectionLabel('Rappels'),
          _Card(children: [
            _SwitchTile(
              icon: Icons.medication_rounded,
              iconColor: const Color(0xFF405667),
              iconBg: const Color(0xFF405667).withOpacity(0.1) as Color,
              label: 'Médicaments',
              subtitle: 'Rappels de prise de médicaments',
              value: _medications && _pushEnabled,
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _medications = v),
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.directions_run_rounded,
              iconColor: const Color(0xFF00B285),
              iconBg: const Color(0xFFE0F7F1),
              label: 'Activités physiques',
              subtitle: 'Objectifs et bilans quotidiens',
              value: _activities && _pushEnabled,
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _activities = v),
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.calendar_month_rounded,
              iconColor: const Color(0xFF5D95D6),
              iconBg: const Color(0xFFE8F1FB),
              label: 'Rendez-vous',
              subtitle: 'Rappels avant chaque rendez-vous',
              value: _appointments && _pushEnabled,
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _appointments = v),
            ),
            _Divider(),
            _SwitchTile(
              icon: Icons.people_rounded,
              iconColor: const Color(0xFFD85A30),
              iconBg: const Color(0xFFFAECE7),
              label: 'Alertes aidants',
              subtitle: 'Messages de vos proches aidants',
              value: _caregiverAlerts && _pushEnabled,
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _caregiverAlerts = v),
            ),
          ]),
          const SizedBox(height: 8),

          // ── Résumés ───────────────────────────────────────
          _SectionLabel('Résumés'),
          _Card(children: [
            _SwitchTile(
              icon: Icons.bar_chart_rounded,
              iconColor: const Color(0xFF405667),
              iconBg: const Color(0xFF405667).withOpacity(0.1) as Color,
              label: 'Rapport hebdomadaire',
              subtitle: 'Résumé de santé chaque lundi',
              value: _weeklyReport && _pushEnabled,
              enabled: _pushEnabled,
              onChanged: (v) => setState(() => _weeklyReport = v),
            ),
          ]),
          const SizedBox(height: 8),

          // ── E-mail ────────────────────────────────────────
          _SectionLabel('E-mail'),
          _Card(children: [
            _SwitchTile(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF5D95D6),
              iconBg: const Color(0xFFE8F1FB),
              label: 'Notifications par e-mail',
              subtitle: 'Recevoir les alertes importantes par courriel',
              value: _emailEnabled,
              onChanged: (v) => setState(() => _emailEnabled = v),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Bouton enregistrer ────────────────────────────
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const TrText('Préférences enregistrées.'),
                  backgroundColor: const Color(0xFF405667),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF405667),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const TrText(
              'Enregistrer',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Widgets locaux ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
        child: TrText(
          text,
          style: const TextStyle(
            color: Color(0xFF5D95D6),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
      height: 0, indent: 58, endIndent: 16, color: Color(0xFFF0EDEA));
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TrText(label,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF3D3530),
                          fontWeight: FontWeight.w500)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFAFAFAF))),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: const Color(0xFF405667),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
