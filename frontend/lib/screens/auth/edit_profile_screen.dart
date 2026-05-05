import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart' as cp;

import '../../provider/auth_provider.dart';
import '../../widgets/tr_text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCountry = "Canada";
  DateTime _selectedDate = DateTime(1990, 1, 1);
  bool _isLoading = false;

  // Sécurité app
  bool _securiteActivee = false;
  String _methodeSecurite = 'aucune'; // 'aucune' | 'pin' | 'biometrique'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      setState(() {
        _nameController.text = auth.firstName ?? "";
        _emailController.text = auth.email ?? "";
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Erreur image: $e");
    }
  }

  void _showCountryPicker() {
    cp.showCountryPicker(
      context: context,
      showPhoneCode: false,
      countryListTheme: cp.CountryListThemeData(
        backgroundColor: const Color(0xFF0A1628),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        searchTextStyle: const TextStyle(color: Colors.white),
        textStyle: const TextStyle(color: Colors.white),
        inputDecoration: InputDecoration(
          hintText: 'Chercher un pays...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF7DC4FF), width: 1.5),
          ),
        ),
      ),
      onSelect: (cp.Country country) {
        setState(() => _selectedCountry = country.displayNameNoCountryCode);
      },
    );
  }

  void _showSetPinDialog() {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscure1 = true;
    bool obscure2 = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0A1628),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Définir un code PIN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ce code sera demandé à chaque ouverture après verrouillage.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _dialogPinField(
                controller: pinController,
                label: 'Code PIN (4-6 chiffres)',
                obscure: obscure1,
                onToggle: () => setDialogState(() => obscure1 = !obscure1),
              ),
              const SizedBox(height: 12),
              _dialogPinField(
                controller: confirmController,
                label: 'Confirmer le PIN',
                obscure: obscure2,
                onToggle: () => setDialogState(() => obscure2 = !obscure2),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final pin = pinController.text.trim();
                final confirm = confirmController.text.trim();

                if (pin.length < 4 || pin.length > 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    _snackBar(
                      'Le PIN doit contenir 4 à 6 chiffres.',
                      isError: true,
                    ),
                  );
                  return;
                }
                if (pin != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    _snackBar(
                      'Les codes PIN ne correspondent pas.',
                      isError: true,
                    ),
                  );
                  return;
                }

                // TODO: sauvegarder le PIN de manière sécurisée
                setState(() {
                  _securiteActivee = true;
                  _methodeSecurite = 'pin';
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(_snackBar('Code PIN défini avec succès.'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A9FE8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogPinField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 18,
        letterSpacing: 6,
      ),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
        ),
        counterText: '',
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white.withOpacity(0.35),
            size: 18,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF7DC4FF), width: 1.5),
        ),
      ),
    );
  }

  SnackBar _snackBar(String message, {bool isError = false}) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: isError
          ? const Color(0xFFEF4444)
          : const Color(0xFF10B981),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(24),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    try {
      if (_image != null) await auth.updateProfilePicture(_image!.path);
      await auth.updateUserInfo(newName: _nameController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_snackBar("Profil mis à jour avec succès"));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snackBar("Erreur lors de la mise à jour", isError: true),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final auth = context.watch<AuthProvider>();

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
                      const Color(0xFF004E92).withOpacity(0.5),
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
                      Colors.white.withOpacity(0.04),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildAvatarHero(auth),
                            const SizedBox(height: 28),
                            _buildPersonalCard(),
                            const SizedBox(height: 16),
                            _buildSecurityCard(),
                            const SizedBox(height: 16),
                            _buildLocationCard(),
                            const SizedBox(height: 24),
                            _buildSaveButton(),
                          ],
                        ),
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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
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
            "Modifier le Profil",
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

  // ─── AVATAR ────────────────────────────────────────────────────────────────

  Widget _buildAvatarHero(AuthProvider auth) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF4A9FE8).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004E92).withOpacity(0.5),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 56,
                backgroundColor: const Color(0xFF004E92).withOpacity(0.5),
                child: ClipOval(
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: _buildProfileImage(auth),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A9FE8), Color(0xFF004E92)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF000428),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : "Votre nom",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text.isNotEmpty ? _emailController.text : "",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.45),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(AuthProvider auth) {
    if (_image != null) return Image.file(_image!, fit: BoxFit.cover);
    final imagePath = auth.profilePicture;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.person,
            size: 60,
            color: const Color(0xFF7DC4FF).withOpacity(0.7),
          ),
        );
      }
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.person,
          size: 60,
          color: const Color(0xFF7DC4FF).withOpacity(0.7),
        ),
      );
    }
    return Icon(
      Icons.person,
      size: 60,
      color: const Color(0xFF7DC4FF).withOpacity(0.7),
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
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withOpacity(0.3),
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
                  color: const Color(0xFF004E92).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.08), height: 24),
          ...children,
        ],
      ),
    );
  }

  // ─── PERSONAL CARD ─────────────────────────────────────────────────────────

  Widget _buildPersonalCard() {
    return _buildGlassCard(
      sectionIcon: Icons.person_outline_rounded,
      sectionTitle: "Informations personnelles",
      children: [
        _buildField(
          controller: _nameController,
          label: "Nom complet",
          icon: Icons.person_outline_rounded,
          hint: "Votre nom",
          cap: TextCapitalization.words,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 14),
        _buildField(
          controller: _emailController,
          label: "Email",
          icon: Icons.alternate_email_rounded,
          hint: "votre@email.com",
          type: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  // ─── SECURITY CARD ─────────────────────────────────────────────────────────

  Widget _buildSecurityCard() {
    return _buildGlassCard(
      sectionIcon: Icons.shield_outlined,
      sectionTitle: "Sécurité de l'application",
      children: [
        // Description
        Text(
          "Protégez l'accès à l'application après verrouillage de votre téléphone.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.45),
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        // Toggle activation sécurité
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _securiteActivee
                ? const Color(0xFF10B981).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _securiteActivee
                  ? const Color(0xFF10B981).withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _securiteActivee ? Icons.lock_rounded : Icons.lock_open_rounded,
                color: _securiteActivee
                    ? const Color(0xFF34D399)
                    : Colors.white.withOpacity(0.3),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TrText(
                      "Verrouillage activé",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _securiteActivee
                          ? "L'app est protégée"
                          : "Aucune protection active",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: _securiteActivee,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF10B981),
                  inactiveThumbColor: Colors.white.withOpacity(0.3),
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  onChanged: (val) {
                    if (!val) {
                      setState(() {
                        _securiteActivee = false;
                        _methodeSecurite = 'aucune';
                      });
                    } else {
                      setState(() => _securiteActivee = true);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Méthodes de déverrouillage (visible si sécurité activée)
        if (_securiteActivee) ...[
          const SizedBox(height: 14),
          Text(
            "Méthode de déverrouillage",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),

          // Option PIN
          _buildMethodeTile(
            icon: Icons.pin_outlined,
            label: "Code PIN",
            subtitle: "4 à 6 chiffres personnalisés",
            isSelected: _methodeSecurite == 'pin',
            onTap: () => _showSetPinDialog(),
          ),

          const SizedBox(height: 8),

          // Option Biométrique
          _buildMethodeTile(
            icon: Icons.fingerprint_rounded,
            label: "Biométrie",
            subtitle: "Empreinte digitale ou Face ID",
            isSelected: _methodeSecurite == 'biometrique',
            onTap: () {
              setState(() => _methodeSecurite = 'biometrique');
              ScaffoldMessenger.of(context).showSnackBar(
                _snackBar('Biométrie sélectionnée comme méthode.'),
              );
            },
          ),
        ],

        // Statut actuel
        if (_securiteActivee && _methodeSecurite != 'aucune') ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A9FE8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4A9FE8).withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: const Color(0xFF7DC4FF).withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _methodeSecurite == 'pin'
                        ? "Code PIN actif — requis à chaque ouverture après verrouillage"
                        : "Biométrie active — scan requis à l'ouverture",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMethodeTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF004E92).withOpacity(0.4)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A9FE8).withOpacity(0.55)
                : Colors.white.withOpacity(0.08),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A9FE8).withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF7DC4FF)
                    : Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.55),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(isSelected ? 0.5 : 0.3),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A9FE8).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Color(0xFF7DC4FF),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.white.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }

  // ─── LOCATION CARD ─────────────────────────────────────────────────────────

  Widget _buildLocationCard() {
    return _buildGlassCard(
      sectionIcon: Icons.public_rounded,
      sectionTitle: "Localisation",
      children: [
        _buildPickerTile(
          icon: Icons.calendar_today_rounded,
          label: "Date de naissance",
          value:
              "${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
          valueColor: const Color(0xFF7DC4FF),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: Color(0xFF7DC4FF),
                    onSurface: Colors.white,
                    surface: Color(0xFF0A1628),
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _selectedDate = picked);
          },
        ),
        const SizedBox(height: 12),
        _buildPickerTile(
          icon: Icons.public_rounded,
          label: "Pays / Région",
          value: _selectedCountry,
          valueColor: const Color(0xFF34D399),
          onTap: _showCountryPicker,
        ),
      ],
    );
  }

  // ─── FIELD ─────────────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool obscure = false,
    bool required = true,
    TextInputType type = TextInputType.text,
    TextCapitalization cap = TextCapitalization.none,
    Widget? suffix,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      textCapitalization: cap,
      enabled: !_isLoading,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontSize: 13,
        ),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.35), size: 19),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
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
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
          : null,
    );
  }

  // ─── PICKER TILE ───────────────────────────────────────────────────────────

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    Color? valueColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.35), size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: valueColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── SAVE BUTTON ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
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
            color: const Color(0xFF004E92).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _save,
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
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  TrText(
                    "Sauvegarder",
                    style: TextStyle(
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
