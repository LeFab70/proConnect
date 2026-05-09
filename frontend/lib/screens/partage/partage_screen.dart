import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/caregiver.dart';
import '../../provider/caregiver_provider.dart';
import '../../provider/partage_provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/tr_text.dart';

class PartageScreen extends StatefulWidget {
  final dynamic initialData;

  const PartageScreen({super.key, this.initialData});

  @override
  State<PartageScreen> createState() => _PartageScreenState();
}

class _PartageScreenState extends State<PartageScreen> {
  int? _selectedProcheId;
  String _selectedRelation = "Fils / Fille";

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
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final auth = context.watch<AuthProvider>();
    final caregiverProv = context.watch<CaregiverProvider>();
    final partageProv = context.watch<PartageProvider>();

    final isAineConnecte = auth.isAine;
    final caregivers = caregiverProv.caregivers;

    final dropdownValue = caregivers.any((c) => c.id == _selectedProcheId)
        ? _selectedProcheId
        : null;

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
    // Pas aîné
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
              Text(
                "Accès restreint",
                style: const TextStyle(
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

    // Chargement
    if (caregiverProv.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.white.withValues(alpha: 0.6),
          strokeWidth: 2,
        ),
      );
    }

    // Aucun proche
    if (caregivers.isEmpty) {
      return Center(
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
                Icons.people_outline_rounded,
                size: 40,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Aucun proche disponible",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Contenu principal
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card dropdown proche
                _buildGlassCard(
                  sectionIcon: Icons.person_add_alt_1_rounded,
                  sectionTitle: "Proche aidant",
                  children: [
                    Text(
                      "Sélectionnez le proche avec qui partager votre suivi",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(caregivers, dropdownValue),
                  ],
                ),

                const SizedBox(height: 16),

                // Card relation
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

                // Récap si proche sélectionné
                if (dropdownValue != null)
                  _buildRecapCard(caregivers, dropdownValue),
              ],
            ),
          ),
        ),

        // Bouton submit fixe en bas
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
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildRecapCard(List<Caregiver> caregivers, int selectedId) {
    final proche = caregivers.firstWhere((c) => c.id == selectedId);
    final initiales =
        "${proche.prenom.isNotEmpty ? proche.prenom[0] : ''}${proche.nom.isNotEmpty ? proche.nom[0] : ''}"
            .toUpperCase();

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
                  "${proche.prenom} ${proche.nom}".trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 12,
                      color: const Color(0xFF34D399),
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
    final canSubmit = dropdownValue != null && !partageProv.isLoading;

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
            : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: ElevatedButton(
        onPressed: canSubmit
            ? () async {
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(context);
                final proche = caregiverProv.caregivers.firstWhere(
                  (c) => c.id == _selectedProcheId!,
                );

                final success = await partageProv.aineAjouteProche(
                  aineId: auth.currentUserLocalId ?? 0,
                  procheId: _selectedProcheId!,
                  relation: _selectedRelation,
                  auth: auth,

                  // Infos du proche
                  procheEmail: proche.email,
                  procheNom: proche.nom,
                  prochePrenom: proche.prenom,
                  procheTelephone: proche.telephone,

                  // Infos de l’aîné
                  aineNom: auth.nom,
                  ainePrenom: auth.prenom,
                  aineEmail: auth.email,
                );

                if (!mounted) return;
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: const TrText(
                        "Suivi partagé avec succès !",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
            : null,
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
                    Icons.share_rounded,
                    color: canSubmit
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Partager mon suivi",
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
