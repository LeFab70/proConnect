import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/medication.dart';
import '../../models/rappel.dart';
import '../../provider/auth_provider.dart';
import '../../provider/medication_provider.dart';
import '../../provider/rappel_provider.dart';
import '../../services/notification_service.dart';

class AddMedicationScreen extends StatefulWidget {
  final String? id;
  final String? initialName;
  final String? initialMarque;
  final String? initialDosage;
  final List<String>? initialSchedules;
  final String? initialUrlPhoto;
  final int initialAineId;
  final bool initialIsActive;

  const AddMedicationScreen({
    super.key,
    this.id,
    this.initialName,
    this.initialMarque,
    this.initialDosage,
    this.initialSchedules,
    this.initialUrlPhoto,
    this.initialAineId = 1,
    this.initialIsActive = true,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _marqueController;
  late final TextEditingController _dosageController;
  late final TextEditingController _urlPhotoController;

  final List<TimeOfDay> _selectedTimes = [];
  bool _isLoading = false;
  late bool _isActive;

  bool get _isEditMode => widget.id != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _marqueController = TextEditingController(text: widget.initialMarque ?? '');
    _dosageController = TextEditingController(text: widget.initialDosage ?? '');
    _urlPhotoController = TextEditingController(text: widget.initialUrlPhoto ?? '');
    _isActive = widget.initialIsActive;

    for (final time in widget.initialSchedules ?? []) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        _selectedTimes.add(
          TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _marqueController.dispose();
    _dosageController.dispose();
    _urlPhotoController.dispose();
    super.dispose();
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

    if (picked == null) return;

    setState(() {
      final exists = _selectedTimes.any(
        (t) => t.hour == picked.hour && t.minute == picked.minute,
      );
      if (!exists) {
        _selectedTimes.add(picked);
        _selectedTimes.sort((a, b) =>
            (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
      }
    });
  }

  List<String> _formattedSchedules() {
    final times = _selectedTimes
        .map((t) =>
            '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toSet()
        .toList();
    times.sort();
    return times;
  }

  DateTime _dateTimeFromSchedule(String schedule) {
    final now = DateTime.now();
    final parts = schedule.split(':');
    final hour = int.tryParse(parts[0]) ?? now.hour;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // Fabrice | 2026-05-05T04:56:37Z | Types rappels alignés sur RappelRequestValidation.TypeMedicament.
  String _heureBackendFromSchedule(String schedule) {
    final parts = schedule.split(':');
    final h = (parts.isNotEmpty ? parts[0] : '08').padLeft(2, '0');
    final m = (parts.length > 1 ? parts[1] : '0').padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _createRappelsForMedication({
    required RappelProvider rappelProvider,
    required AuthProvider auth,
    required int medId,
    required String name,
    required List<String> schedules,
  }) async {
    await rappelProvider.deleteRappelByMedicamentId(medId, auth);

    for (final schedule in schedules) {
      var dateHeurePrise = _dateTimeFromSchedule(schedule);
      const minutesAvant = 10;

      if (dateHeurePrise.isBefore(DateTime.now())) {
        dateHeurePrise = dateHeurePrise.add(const Duration(days: 1));
      }

      final heureBackend = _heureBackendFromSchedule(schedule);

      final rappel = Rappel(
        id: DateTime.now().microsecondsSinceEpoch,
        dateDebut: DateTime.now(),
        heureDebut: heureBackend,
        minutesAvantRappel: minutesAvant,
        dateHeurePrise: dateHeurePrise,
        dateHeureNotification: dateHeurePrise.subtract(
          const Duration(minutes: minutesAvant),
        ),
        type: 'Medicament',
        actif: true,
        medicamentId: medId,
        groupeId: 'med_$medId',
      );

      await rappelProvider.addRappel(rappel, auth);
    }

    await rappelProvider.fetchRappels(auth);

    for (final r
        in rappelProvider.rappels.where((x) => x.medicamentId == medId)) {
      try {
        await NotificationService.scheduleDailyRappel(
          id: r.id,
          title: 'Rappel médicament',
          body: 'Il est temps de prendre $name',
          dateTime: r.dateHeureNotification,
        );
      } catch (e) {
        debugPrint('Erreur notification médicament: $e');
      }
    }
  }

  Future<void> _saveMedication() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTimes.isEmpty) {
      _showSnackBar('Ajoutez au moins une heure de prise', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final schedules = _formattedSchedules();
      final medicationProvider = context.read<MedicationProvider>();
      final rappelProvider = context.read<RappelProvider>();
      final auth = context.read<AuthProvider>();

      final name = _nameController.text.trim();
      final marque = _marqueController.text.trim();
      final dosage = _dosageController.text.trim();
      final urlPhoto = _urlPhotoController.text.trim().isEmpty
          ? null
          : _urlPhotoController.text.trim();

      final bool success;

      if (_isEditMode) {
        success = await medicationProvider.updateMedication(
          widget.id!, name, marque, dosage, schedules,
          urlPhoto: urlPhoto,
          aineId: widget.initialAineId,
          isActive: _isActive,
          auth: auth,
        );

        final medId = int.tryParse(widget.id!);
        if (success && medId != null) {
          if (_isActive) {
            await _createRappelsForMedication(
              rappelProvider: rappelProvider,
              auth: auth,
              medId: medId,
              name: name,
              schedules: schedules,
            );
          } else {
            await rappelProvider.deleteRappelByMedicamentId(medId, auth);
          }
        }
      } else {
        success = await medicationProvider.addMedication(
          name,
          marque,
          dosage,
          schedules,
          urlPhoto: urlPhoto,
          aineId: widget.initialAineId,
          isActive: _isActive,
          auth: auth,
        );

        if (success && _isActive) {
          Medication? match;
          for (final m in medicationProvider.medications) {
            if (m.name == name && m.marque == marque) match = m;
          }
          final medId = match != null ? int.tryParse(match.id) : null;
          if (medId != null) {
            await _createRappelsForMedication(
              rappelProvider: rappelProvider,
              auth: auth,
              medId: medId,
              name: match!.name,
              schedules: match.schedules,
            );
          }
        }
      }

      if (!mounted) return;

      if (success) {
        _showSnackBar(_isEditMode
            ? 'Médicament modifié avec succès'
            : 'Médicament ajouté avec succès');
        Navigator.pop(context);
      } else {
        _showSnackBar("Erreur lors de l'enregistrement", isError: true);
      }
    } catch (e) {
      debugPrint('Erreur médicament: $e');
      _showSnackBar('Une erreur inattendue est survenue', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMedication() async {
    if (!_isEditMode || widget.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Supprimer le médicament',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: TextStyle(color: Colors.white.withOpacity(0.6), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final auth = context.read<AuthProvider>();
    final medId = int.tryParse(widget.id!);
    if (medId != null) {
      await context.read<RappelProvider>().deleteRappelByMedicamentId(
            medId,
            auth,
          );
    }

    final success = await context
        .read<MedicationProvider>()
        .deleteMedication(widget.id!, auth: auth);
    if (!mounted) return;

    if (success) {
      _showSnackBar('Médicament supprimé');
      Navigator.pop(context);
    } else {
      _showSnackBar('Erreur lors de la suppression', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(24),
      ),
    );
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
                  gradient: RadialGradient(colors: [
                    const Color(0xFF004E92).withOpacity(0.55),
                    Colors.transparent,
                  ]),
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
                  gradient: RadialGradient(colors: [
                    Colors.white.withOpacity(0.04),
                    Colors.transparent,
                  ]),
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
                          _buildInfoCard(),
                          const SizedBox(height: 16),
                          _buildSchedulesCard(),
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
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
              ),
              child: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
            ),
          ),

          Column(
            children: [
              Text(
                _isEditMode ? 'Modifier' : 'Nouveau médicament',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              if (_isEditMode)
                Text(
                  widget.initialName ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          _isEditMode
              ? GestureDetector(
                  onTap: _isLoading ? null : _deleteMedication,
                  child: Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: Color(0xFFFF7070)),
                  ),
                )
              : const SizedBox(width: 44),
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
      padding: const EdgeInsets.all(22),
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
                      color: const Color(0xFF4A9FE8).withOpacity(0.3), width: 1),
                ),
                child: Icon(sectionIcon, color: const Color(0xFF7DC4FF), size: 17),
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
          Divider(color: Colors.white.withOpacity(0.08), height: 26),
          ...children,
        ],
      ),
    );
  }

  // ─── CHAMP TEXTE ───────────────────────────────────────────────────────────

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    String? hint,
    bool required = true,
    TextCapitalization cap = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      enabled: !_isLoading,
      textCapitalization: cap,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
        labelStyle:
            TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
        prefixIcon:
            Icon(icon, color: Colors.white.withOpacity(0.35), size: 19),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF7DC4FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.2),
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

  // ─── CARD INFOS ────────────────────────────────────────────────────────────

  Widget _buildInfoCard() {
    return _buildGlassCard(
      sectionIcon: Icons.medication_rounded,
      sectionTitle: 'Informations du médicament',
      children: [
        _buildField(
          _nameController,
          'Nom du médicament',
          Icons.vaccines_rounded,
          cap: TextCapitalization.words,
        ),
        const SizedBox(height: 14),
        _buildRow(
          left: _buildField(
            _marqueController,
            'Marque',
            Icons.local_pharmacy_outlined,
            cap: TextCapitalization.words,
          ),
          right: _buildField(
            _dosageController,
            'Dosage',
            Icons.monitor_weight_outlined,
            hint: '500mg',
          ),
        ),
        const SizedBox(height: 14),
        _buildField(
          _urlPhotoController,
          'URL photo',
          Icons.image_outlined,
          hint: 'Optionnel',
          type: TextInputType.url,
          required: false,
        ),
      ],
    );
  }

  Widget _buildRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  // ─── CARD HORAIRES ─────────────────────────────────────────────────────────

  Widget _buildSchedulesCard() {
    return _buildGlassCard(
      sectionIcon: Icons.alarm_rounded,
      sectionTitle: 'Heures de prise',
      children: [
        if (_selectedTimes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: Colors.white.withOpacity(0.3)),
                const SizedBox(width: 8),
                Text(
                  'Aucune heure ajoutée',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTimes.map((time) {
              final text =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF7DC4FF)),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7DC4FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () => setState(() => _selectedTimes.remove(time)),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 14),

        GestureDetector(
          onTap: _isLoading ? null : _addTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withOpacity(0.12), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_alarm_rounded,
                    size: 17, color: const Color(0xFF7DC4FF).withOpacity(0.8)),
                const SizedBox(width: 8),
                Text(
                  'Ajouter une heure',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TOGGLE ACTIF ──────────────────────────────────────────────────────────

  Widget _buildActiveToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isActive
            ? const Color(0xFF10B981).withOpacity(0.1)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isActive
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isActive
                ? Icons.notifications_active_rounded
                : Icons.notifications_off_outlined,
            color: _isActive
                ? const Color(0xFF34D399)
                : Colors.white.withOpacity(0.3),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activer les rappels',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isActive
                      ? 'Des notifications seront envoyées'
                      : 'Aucun rappel ne sera envoyé',
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
              value: _isActive,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF10B981),
              inactiveThumbColor: Colors.white.withOpacity(0.3),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              onChanged: _isLoading
                  ? null
                  : (v) => setState(() => _isActive = v),
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
            color: const Color(0xFF004E92).withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isEditMode ? Icons.check_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Mettre à jour' : 'Enregistrer',
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