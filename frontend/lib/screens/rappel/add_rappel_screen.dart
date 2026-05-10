import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/rappel.dart';
import '../../provider/auth_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../services/local_alarm_service.dart';

class AddRappelScreen extends StatefulWidget {
  final Rappel? rappel;

  const AddRappelScreen({super.key, this.rappel});

  bool get isEditing => rappel != null;

  @override
  State<AddRappelScreen> createState() => _AddRappelScreenState();
}

class _AddRappelScreenState extends State<AddRappelScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _dateDebut;
  late TimeOfDay _heureDebut;
  late int _minutesAvantRappel;
  late String _type;
  late bool _actif;

  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();

  bool _isLoading = false;

  int? _medicamentId;
  int? _rendezVousMedicalId;

  @override
  void initState() {
    super.initState();
    final rappel = widget.rappel;
    _dateDebut = rappel?.dateDebut ?? DateTime.now();

    if (rappel != null) {
      final parts = rappel.heureDebut.split(':');
      _heureDebut = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? TimeOfDay.now().hour,
        minute: parts.length > 1
            ? int.tryParse(parts[1]) ?? TimeOfDay.now().minute
            : TimeOfDay.now().minute,
      );
    } else {
      _heureDebut = TimeOfDay.now();
    }

    _minutesAvantRappel = rappel?.minutesAvantRappel ?? 15;
    _type = rappel?.type ?? 'medicament';
    _actif = rappel?.actif ?? true;
    _medicamentId = rappel?.medicamentId;
    _rendezVousMedicalId = rappel?.rendezVousMedicalId;

    _typeController.text = _type;
    _minutesController.text = _minutesAvantRappel.toString();
  }

  @override
  void dispose() {
    _typeController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
    if (picked != null) setState(() => _dateDebut = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureDebut,
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
    if (picked != null) setState(() => _heureDebut = picked);
  }

  Future<void> _saveRappel() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<RappelProvider>();
    final auth = context.read<AuthProvider>();
    final minutes = int.parse(_minutesController.text.trim());

    final dateHeurePrise = DateTime(
      _dateDebut.year,
      _dateDebut.month,
      _dateDebut.day,
      _heureDebut.hour,
      _heureDebut.minute,
    );

    final dateHeureNotification = dateHeurePrise.subtract(
      Duration(minutes: minutes),
    );

    final rappel = Rappel(
      id: widget.rappel?.id ?? DateTime.now().microsecondsSinceEpoch,
      dateDebut: _dateDebut,
      heureDebut: _formatTime(_heureDebut),
      minutesAvantRappel: minutes,
      dateHeurePrise: dateHeurePrise,
      dateHeureNotification: dateHeureNotification,
      type: _typeController.text.trim(),
      actif: _actif,
      medicamentId: _medicamentId,
      rendezVousMedicalId: _rendezVousMedicalId,
      groupeId: widget.rappel?.groupeId,
    );

    final success = widget.isEditing
        ? await provider.updateRappel(rappel, auth)
        : await provider.addRappel(rappel, auth);

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (success) {
      await LocalAlarmService.cancelAlarm(rappel.id);

      if (rappel.actif) {
        await LocalAlarmService.scheduleAlarm(
          id: rappel.id,
          title: 'Rappel ProConnectNB',
          body: rappel.type,
          dateTime: rappel.dateHeureNotification,
        );
      }

      setState(() => _isLoading = false);

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Rappel modifié avec succès.'
                : 'Rappel ajouté avec succès.',
            style: const TextStyle(
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
    } else {
      setState(() => _isLoading = false);

      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Erreur lors de l\'enregistrement.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');

    return '$h:$m:00';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
                          _buildTypeCard(),
                          const SizedBox(height: 16),
                          _buildDateTimeCard(),
                          const SizedBox(height: 16),
                          _buildMinutesCard(),
                          const SizedBox(height: 16),
                          _buildActiveToggle(),
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

  // ─── HEADER ────────────────────────────────────────────────────────────────

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
                widget.isEditing ? 'Modifier le rappel' : 'Nouveau rappel',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (widget.isEditing)
                Text(
                  widget.rappel?.type ?? '',
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

  // ─── CHAMP TEXTE ───────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      enabled: !_isLoading,
      inputFormatters: formatters,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 13,
        ),
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.35),
          size: 19,
        ),
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
      validator: validator,
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
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 19),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── CARDS ─────────────────────────────────────────────────────────────────

  Widget _buildTypeCard() {
    return _buildGlassCard(
      sectionIcon: Icons.label_outline_rounded,
      sectionTitle: 'Type de rappel',
      children: [
        _buildTextField(
          controller: _typeController,
          label: 'Type de rappel',
          icon: Icons.alarm_rounded,
          hint: 'Ex: médicament, rendez-vous',
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Le type est obligatoire.'
              : null,
        ),
      ],
    );
  }

  Widget _buildDateTimeCard() {
    return _buildGlassCard(
      sectionIcon: Icons.calendar_month_rounded,
      sectionTitle: 'Date & Heure',
      children: [
        _buildPickerTile(
          icon: Icons.calendar_today_rounded,
          label: 'Date de début',
          value: _formatDate(_dateDebut),
          valueColor: const Color(0xFF7DC4FF),
          onTap: _pickDate,
        ),
        const SizedBox(height: 12),
        _buildPickerTile(
          icon: Icons.access_time_rounded,
          label: 'Heure de prise',
          value: _formatTime(_heureDebut),
          valueColor: const Color(0xFF34D399),
          onTap: _pickTime,
        ),
      ],
    );
  }

  Widget _buildMinutesCard() {
    return _buildGlassCard(
      sectionIcon: Icons.timer_outlined,
      sectionTitle: 'Délai de notification',
      children: [
        Text(
          'Combien de minutes avant la prise souhaitez-vous être notifié ?',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.45),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _minutesController,
          label: 'Minutes avant rappel',
          icon: Icons.notifications_none_rounded,
          hint: '15',
          type: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            final minutes = int.tryParse(value ?? '');
            if (minutes == null) return 'Entrez un nombre valide.';
            if (minutes < 0 || minutes > 10080) {
              return 'Valeur entre 0 et 10080.';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        // Suggestions rapides
        Row(
          children: [5, 10, 15, 30].map((min) {
            final isSelected = _minutesController.text == min.toString();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _minutesController.text = min.toString()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF004E92).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A9FE8).withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${min}min',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF7DC4FF)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── TOGGLE ACTIF ──────────────────────────────────────────────────────────

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _actif
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _actif
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _actif
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: _actif
                ? const Color(0xFF34D399)
                : Colors.white.withValues(alpha: 0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rappel actif',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _actif
                      ? 'Vous recevrez une notification'
                      : 'Aucune notification ne sera envoyée',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: _actif,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF10B981),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.3),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              onChanged: _isLoading ? null : (v) => setState(() => _actif = v),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOUTON SUBMIT ─────────────────────────────────────────────────────────

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
        onPressed: _isLoading ? null : _saveRappel,
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
                    widget.isEditing
                        ? Icons.check_rounded
                        : Icons.add_alarm_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEditing
                        ? 'Enregistrer les modifications'
                        : 'Ajouter le rappel',
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
