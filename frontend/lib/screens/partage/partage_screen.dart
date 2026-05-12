import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/caregiver.dart';
import '../../models/partage_suivi.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/settings_provider.dart';
import '../../provider/partage_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/tr_text.dart';
import '../../widgets/app_background.dart';

class PartageScreen extends StatefulWidget {
  final dynamic initialData;

  const PartageScreen({super.key, this.initialData});

  @override
  State<PartageScreen> createState() => _PartageScreenState();
}

class _PartageScreenState extends State<PartageScreen> {
  // Mode : 0 = proche existant, 1 = inviter par courriel
  int _mode = 0;

  int? _selectedProcheId;
  String _selectedRelation = "Fils / Fille";
  final _emailCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();

  final List<String> _relations = [
    "Fils / Fille",
    "Conjoint(e)",
    "Parent",
    "Ami(e)",
    "Autre",
  ];

  final List<IconData> _relationIcons = [
    Icons.family_restroom_rounded,
    Icons.favorite_border_rounded,
    Icons.elderly_rounded,
    Icons.people_outline_rounded,
    Icons.person_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData is Caregiver) {
      final caregiver = widget.initialData as Caregiver;
      _selectedProcheId = caregiver.id;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<CaregiverProvider>().fetchCaregivers(auth);
      context.read<PartageProvider>().fetchPartages(auth);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    final auth = context.watch<AuthProvider>();
    final caregiverProv = context.watch<CaregiverProvider>();
    final partageProv = context.watch<PartageProvider>();
    final isAineConnecte = auth.isAine;
    final aineId = auth.currentUserLocalId ?? 0;

    // Seulement les proches sans lien actif ou en attente avec cet aîné.
    final dejeLies = partageProv.partages
        .where((p) =>
            p.aineId == aineId &&
            p.statut != StatutPartage.refuse)
        .map((p) => p.procheAidantId)
        .toSet();
    final caregivers = caregiverProv.caregivers
        .where((c) => !dejeLies.contains(c.id))
        .toList();

    final dropdownValue = caregivers.any((c) => c.id == _selectedProcheId)
        ? _selectedProcheId
        : null;

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: _buildBody(
                      context,
                      auth,
                      caregiverProv,
                      partageProv,
                      caregivers,
                      dropdownValue,
                      isAineConnecte,
                    ),
                  ),
                ],
              ),
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
            "Partager mon suivi",
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

  Widget _buildBody(
    BuildContext context,
    AuthProvider auth,
    CaregiverProvider caregiverProv,
    PartageProvider partageProv,
    List<Caregiver> caregivers,
    int? dropdownValue,
    bool isAineConnecte,
  ) {
    if (!isAineConnecte) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Accès restreint",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Seul un aîné peut partager son suivi.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Toggle mode ──────────────────────────────
                _buildModeToggle(),
                const SizedBox(height: 16),

                // ── Sélection du proche ───────────────────────
                if (_mode == 0)
                  _buildGlassCard(
                    sectionIcon: Icons.people_alt_rounded,
                    sectionTitle: "Proche existant",
                    children: [
                      Text(
                        "Sélectionnez un proche qui a déjà un compte",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      caregiverProv.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.white.withValues(alpha: 0.6),
                                strokeWidth: 2,
                              ),
                            )
                          : caregivers.isEmpty
                          ? Text(
                              "Aucun proche disponible dans votre liste.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.4),
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          : _buildDropdown(caregivers, dropdownValue),
                    ],
                  )
                else
                  _buildGlassCard(
                    sectionIcon: Icons.mail_outline_rounded,
                    sectionTitle: "Inviter par courriel",
                    children: [
                      Text(
                        "Entrez le courriel de la personne à inviter. Elle recevra la demande lors de sa prochaine connexion.",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.45),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEmailField(),
                    ],
                  ),

                const SizedBox(height: 16),

                // ── Relation ──────────────────────────────────
                _buildGlassCard(
                  sectionIcon: Icons.favorite_border_rounded,
                  sectionTitle: "Votre relation",
                  children: [
                    Text(
                      "Quel est votre lien avec ce proche ?",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRelationChips(),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Récap ─────────────────────────────────────
                if (_mode == 0 && dropdownValue != null)
                  _buildRecapCard(caregivers, dropdownValue, auth)
                else if (_mode == 1 && _emailCtrl.text.trim().isNotEmpty)
                  _buildEmailRecapCard(auth),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: _buildSubmitButton(
            context,
            auth,
            partageProv,
            caregiverProv,
            dropdownValue,
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _modeTab(0, Icons.people_alt_rounded, "Proche existant"),
          _modeTab(1, Icons.mail_outline_rounded, "Par courriel"),
        ],
      ),
    );
  }

  Widget _modeTab(int index, IconData icon, String label) {
    final isSelected = _mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _mode = index;
          _selectedProcheId = null;
          _emailCtrl.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF004E92).withValues(alpha: 0.7)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF4A9FE8).withValues(alpha: 0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? const Color(0xFF7DC4FF)
                    : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Form(
      key: _emailFormKey,
      child: TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: "exemple@courriel.com",
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.alternate_email_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF4A9FE8),
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Courriel requis';
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
            return 'Courriel invalide';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(List<Caregiver> caregivers, int? dropdownValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dropdownValue != null
              ? const Color(0xFF4A9FE8).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: dropdownValue,
          isExpanded: true,
          dropdownColor: const Color(0xFF0A1628),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          hint: Text(
            "Choisir un proche",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 14,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          items: caregivers.map((c) {
            final initiales =
                "${c.prenom.isNotEmpty ? c.prenom[0] : ''}${c.nom.isNotEmpty ? c.nom[0] : ''}"
                    .toUpperCase();
            return DropdownMenuItem<int>(
              value: c.id,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004E92).withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initiales,
                        style: const TextStyle(
                          color: Color(0xFF7DC4FF),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text("${c.prenom} ${c.nom}".trim()),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedProcheId = val),
        ),
      ),
    );
  }

  Widget _buildRelationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: List.generate(_relations.length, (i) {
        final rel = _relations[i];
        final icon = _relationIcons[i];
        final isSelected = _selectedRelation == rel;

        return GestureDetector(
          onTap: () => setState(() => _selectedRelation = rel),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF004E92).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A9FE8).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected
                      ? const Color(0xFF7DC4FF)
                      : Colors.white.withValues(alpha: 0.35),
                ),
                const SizedBox(width: 6),
                Text(
                  rel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecapCard(
    List<Caregiver> caregivers,
    int selectedId,
    AuthProvider auth,
  ) {
    final proche = caregivers.firstWhere((c) => c.id == selectedId);
    final initiales =
        "${proche.prenom.isNotEmpty ? proche.prenom[0] : ''}${proche.nom.isNotEmpty ? proche.nom[0] : ''}"
            .toUpperCase();
    final nomAine = "${auth.prenom ?? ''} ${auth.nom ?? ''}".trim();
    final nomProche = "${proche.prenom} ${proche.nom}".trim();

    return _recapContainer(
      initiales: initiales,
      nomAine: nomAine,
      nomProche: nomProche,
    );
  }

  Widget _buildEmailRecapCard(AuthProvider auth) {
    final email = _emailCtrl.text.trim();
    final nomAine = "${auth.prenom ?? ''} ${auth.nom ?? ''}".trim();
    return _recapContainer(
      initiales: email.isNotEmpty ? email[0].toUpperCase() : '?',
      nomAine: nomAine,
      nomProche: email,
      isEmail: true,
    );
  }

  Widget _recapContainer({
    required String initiales,
    required String nomAine,
    required String nomProche,
    bool isEmail = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF004E92).withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                initiales,
                style: const TextStyle(
                  color: Color(0xFF7DC4FF),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aîné : $nomAine",
                  style: const TextStyle(
                    color: Color(0xFF7DC4FF),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEmail ? "Invitation → $nomProche" : "Proche : $nomProche",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border_rounded,
                      size: 12,
                      color: Color(0xFF34D399),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _selectedRelation,
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: const Color(0xFF10B981).withValues(alpha: 0.7),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    AuthProvider auth,
    PartageProvider partageProv,
    CaregiverProvider caregiverProv,
    int? dropdownValue,
  ) {
    final emailValid = _mode == 1 &&
        _emailCtrl.text.trim().isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailCtrl.text.trim());

    final canSubmit = !partageProv.isLoading &&
        (_mode == 0 ? dropdownValue != null : emailValid);

    Future<void> onPressed() async {
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      bool success;

      if (_mode == 0) {
        final proche = caregiverProv.caregivers.firstWhere(
          (c) => c.id == _selectedProcheId!,
        );
        success = await partageProv.aineAjouteProche(
          aineId: auth.currentUserLocalId ?? 0,
          procheId: _selectedProcheId!,
          relation: _selectedRelation,
          auth: auth,
          procheEmail: proche.email,
          procheNom: proche.nom,
          prochePrenom: proche.prenom,
          procheTelephone: proche.telephone,
          aineNom: auth.nom,
          ainePrenom: auth.prenom,
          aineEmail: auth.email,
        );
      } else {
        success = await partageProv.aineAjouteProche(
          aineId: auth.currentUserLocalId ?? 0,
          procheId: 0,
          procheEmail: _emailCtrl.text.trim().toLowerCase(),
          relation: _selectedRelation,
          auth: auth,
          aineNom: auth.nom,
          ainePrenom: auth.prenom,
          aineEmail: auth.email,
        );
      }

      if (!context.mounted) return;

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: const TrText(
              "Invitation envoyée !",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(24),
          ),
        );
        navigator.pop();
      } else if (partageProv.error.isNotEmpty) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              partageProv.error,
              style: const TextStyle(
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
    }

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: canSubmit
            ? const LinearGradient(
                colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: canSubmit ? null : Colors.white.withValues(alpha: 0.06),
        boxShadow: canSubmit
            ? [
                BoxShadow(
                  color: const Color(0xFF004E92).withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
        border: canSubmit
            ? null
            : Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
      ),
      child: ElevatedButton(
        onPressed: canSubmit ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 0,
        ),
        child: partageProv.isLoading
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
                    _mode == 1
                        ? Icons.send_rounded
                        : Icons.share_rounded,
                    color: canSubmit
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _mode == 1
                        ? "Envoyer l'invitation"
                        : "Partager mon suivi",
                    style: TextStyle(
                      color: canSubmit
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.25),
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
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
}
