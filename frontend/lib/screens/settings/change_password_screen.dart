import 'package:flutter/material.dart';
import '../../widgets/tr_text.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentCtrl  = TextEditingController();
  final _newCtrl      = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _isLoading   = false;

  // Critères de force du mot de passe
  bool get _hasLength    => _newCtrl.text.length >= 8;
  bool get _hasUppercase => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasDigit     => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial   => _newCtrl.text.contains(RegExp(r'[!@#\$&*~]'));

  int get _strength =>
      [_hasLength, _hasUppercase, _hasDigit, _hasSpecial]
          .where((e) => e)
          .length;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Remplacez par votre appel API réel
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const TrText('Mot de passe modifié avec succès.'),
        backgroundColor: const Color(0xFF405667),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
          'Changer le mot de passe',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Illustration ──────────────────────────────
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF405667).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: Color(0xFF405667), size: 34),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: TrText(
                  'Sécurisez votre compte',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3D3530),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TrText(
                  'Choisissez un mot de passe fort et unique.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),

              // ── Carte formulaire ──────────────────────────
              _Card(children: [
                _PasswordField(
                  controller: _currentCtrl,
                  label: 'Mot de passe actuel',
                  hint: '••••••••',
                  show: _showCurrent,
                  onToggle: () =>
                      setState(() => _showCurrent = !_showCurrent),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Champ requis' : null,
                ),
                const _FieldDivider(),
                _PasswordField(
                  controller: _newCtrl,
                  label: 'Nouveau mot de passe',
                  hint: '••••••••',
                  show: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (v.length < 8) return 'Minimum 8 caractères';
                    return null;
                  },
                ),
                const _FieldDivider(),
                _PasswordField(
                  controller: _confirmCtrl,
                  label: 'Confirmer le mot de passe',
                  hint: '••••••••',
                  show: _showConfirm,
                  onToggle: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Champ requis';
                    if (v != _newCtrl.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // ── Indicateur de force ───────────────────────
              if (_newCtrl.text.isNotEmpty) ...[
                TrText(
                  'Force du mot de passe',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(4, (i) {
                    Color color;
                    if (i < _strength) {
                      color = _strength <= 1
                          ? Colors.redAccent
                          : _strength == 2
                              ? Colors.orange
                              : _strength == 3
                                  ? Colors.amber
                                  : const Color(0xFF00B285);
                    } else {
                      color = const Color(0xFFE0E0E0);
                    }
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        height: 5,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                _Card(children: [
                  _CriteriaRow('Au moins 8 caractères', _hasLength),
                  const _FieldDivider(),
                  _CriteriaRow('Une lettre majuscule', _hasUppercase),
                  const _FieldDivider(),
                  _CriteriaRow('Un chiffre', _hasDigit),
                  const _FieldDivider(),
                  _CriteriaRow('Un caractère spécial (!@#\$&*~)', _hasSpecial),
                ]),
                const SizedBox(height: 20),
              ],

              // ── Bouton ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF405667),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const TrText(
                          'Enregistrer',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widget : champ mot de passe ──────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool show;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.show,
    required this.onToggle,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextFormField(
        controller: controller,
        obscureText: !show,
        validator: validator,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15, color: Color(0xFF3D3530)),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              const TextStyle(fontSize: 13, color: Color(0xFF9E9E9E)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18, color: const Color(0xFFAFAFAF)),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}

// ── Widget : critère ─────────────────────────────────────────

class _CriteriaRow extends StatelessWidget {
  final String label;
  final bool met;
  const _CriteriaRow(this.label, this.met);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: met ? const Color(0xFF00B285) : const Color(0xFFCBCBCB),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: met ? const Color(0xFF3D3530) : const Color(0xFFAFAFAF))),
        ],
      ),
    );
  }
}

// ── Widgets partagés ─────────────────────────────────────────

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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );
}

class _FieldDivider extends StatelessWidget {
  const _FieldDivider();
  @override
  Widget build(BuildContext context) => const Divider(
      height: 0, indent: 16, endIndent: 16, color: Color(0xFFF0EDEA));
}
