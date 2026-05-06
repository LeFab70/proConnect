import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/caregiver.dart';
import '../../models/adresse.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/partage_provider.dart';
import '../../widgets/tr_text.dart';

class AddCaregiverScreen extends StatefulWidget {
  final Caregiver? caregiver;

  const AddCaregiverScreen({super.key, this.caregiver});

  @override
  State<AddCaregiverScreen> createState() => _AddCaregiverScreenState();
}

class _AddCaregiverScreenState extends State<AddCaregiverScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _numeroCtrl;
  late TextEditingController _rueCtrl;
  late TextEditingController _villeCtrl;
  late TextEditingController _cpCtrl;
  late TextEditingController _provinceCtrl;

  bool _isLoading = false;

  bool get _isEditing => widget.caregiver != null;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: widget.caregiver?.nom ?? '');
    _prenomCtrl = TextEditingController(text: widget.caregiver?.prenom ?? '');
    _telCtrl = TextEditingController(text: widget.caregiver?.telephone ?? '');
    _emailCtrl = TextEditingController(text: widget.caregiver?.email ?? '');
    _numeroCtrl = TextEditingController(
      text: widget.caregiver?.adresse?.numero ?? '',
    );
    _rueCtrl = TextEditingController(
      text: widget.caregiver?.adresse?.rue ?? '',
    );
    _villeCtrl = TextEditingController(
      text: widget.caregiver?.adresse?.ville ?? '',
    );
    _cpCtrl = TextEditingController(
      text: widget.caregiver?.adresse?.codePostal ?? '',
    );
    _provinceCtrl = TextEditingController(
      text: widget.caregiver?.adresse?.province ?? 'NB',
    );
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _numeroCtrl.dispose();
    _rueCtrl.dispose();
    _villeCtrl.dispose();
    _cpCtrl.dispose();
    _provinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final caregiverProvider = context.read<CaregiverProvider>();
    final partageProvider = context.read<PartageProvider>();
    final auth = context.read<AuthProvider>();

    final nom = _nomCtrl.text.trim();
    final prenom = _prenomCtrl.text.trim();
    final telephone = _telCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    // Fabrice | 2026-05-05T05:02:10Z | AdresseDto complet pour POST proche aidant.
    final adresse = Adresse(
      numero: _numeroCtrl.text.trim(),
      rue: _rueCtrl.text.trim(),
      ville: _villeCtrl.text.trim(),
      codePostal: _cpCtrl.text.trim(),
      province: _provinceCtrl.text.trim().isEmpty
          ? 'NB'
          : _provinceCtrl.text.trim(),
    );

    bool success;

    if (!_isEditing) {
      success = await caregiverProvider.addCaregiver(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        email: email,
        adresse: adresse,
        auth: auth,
      );

      if (success && caregiverProvider.caregivers.isNotEmpty) {
        final caregiver = caregiverProvider.caregivers.last;
        await partageProvider.aineAjouteProche(
          aineId: auth.currentUserLocalId ?? 0,
          procheId: caregiver.id,
          relation: "Proche aidant",
          procheEmail: email,
          auth: auth,
        );
      }
    } else {
      success = await caregiverProvider.updateCaregiver(widget.caregiver!.id, {
        "nom": nom,
        "prenom": prenom,
        "telephone": telephone,
        "email": email,
        "adresse": adresse.toJson(),
      }, auth);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
              top: -60,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF004E92).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Orb bas-gauche
            Positioned(
              bottom: 80,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
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
                  _buildHeader(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                        children: [
                          _buildPersonalCard(),
                          const SizedBox(height: 16),
                          _buildAddressCard(),
                          const SizedBox(height: 24),
                          _buildSubmitButton(),
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

  Widget _buildHeader() {
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
                Icons.close_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          Column(
            children: [
              Text(
                _isEditing ? "Modifier le proche" : "Nouveau proche",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (_isEditing)
                Text(
                  "${widget.caregiver?.prenom ?? ''} ${widget.caregiver?.nom ?? ''}"
                      .trim(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.45),
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

  Widget _buildGlassCard({
    required IconData sectionIcon,
    required String sectionTitle,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 26),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPersonalCard() {
    return _buildGlassCard(
      sectionIcon: Icons.person_outline_rounded,
      sectionTitle: "Informations personnelles",
      children: [
        _buildRow(
          left: _buildField(_prenomCtrl, "Prénom", Icons.person_rounded),
          right: _buildField(_nomCtrl, "Nom", Icons.person_outline_rounded),
        ),
        const SizedBox(height: 14),
        _buildField(
          _telCtrl,
          "Téléphone",
          Icons.phone_rounded,
          type: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _buildField(
          _emailCtrl,
          "Email",
          Icons.alternate_email_rounded,
          type: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return _buildGlassCard(
      sectionIcon: Icons.location_on_outlined,
      sectionTitle: "Adresse",
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: _buildField(
                _numeroCtrl,
                "No. civique",
                Icons.numbers_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildField(_rueCtrl, "Rue", Icons.signpost_outlined),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildRow(
          left: _buildField(_villeCtrl, "Ville", Icons.location_city_rounded),
          right: _buildField(
            _cpCtrl,
            "Code postal",
            Icons.markunread_mailbox_outlined,
            type: TextInputType.text,
          ),
        ),
        const SizedBox(height: 14),
        _buildField(
          _provinceCtrl,
          "Province",
          Icons.flag_outlined,
        ),
      ],
    );
  }

  /// Two fields side by side
  Widget _buildRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      enabled: !_isLoading,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 19),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7DC4FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF7070), fontSize: 11),
      ),
      validator: (v) => v == null || v.trim().isEmpty ? "Obligatoire" : null,
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004E92).withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditing
                        ? Icons.check_rounded
                        : Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  TrText(
                    _isEditing ? "Mettre à jour" : "Enregistrer le proche",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
