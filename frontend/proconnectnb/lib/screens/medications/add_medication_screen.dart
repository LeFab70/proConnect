import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/medication_provider.dart';

class AddMedicationScreen extends StatefulWidget {
  final String? id;
  final String? initialName;
  final String? initialDosage;
  final String? initialTime;

  const AddMedicationScreen({
    super.key,
    this.id,
    this.initialName,
    this.initialDosage,
    this.initialTime,
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;

  TimeOfDay? _selectedTime;
  bool _isLoading = false;

  bool get _isEditMode => widget.id != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _dosageController = TextEditingController(text: widget.initialDosage ?? '');

    if (widget.initialTime != null) {
      final List<String> parts = widget.initialTime!.split(':');
      if (parts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? TimeOfDay.now().hour,
          minute: int.tryParse(parts[1]) ?? TimeOfDay.now().minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0052D4),
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTime == null) {
      _showSnackBar("Veuillez sélectionner une heure de prise", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String formattedTime =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );
      bool success;

      if (_isEditMode) {
        success = await medicationProvider.updateMedication(
          widget.id!,
          _nameController.text.trim(),
          _dosageController.text.trim(),
          formattedTime,
        );
      } else {
        success = await medicationProvider.addMedication(
          _nameController.text.trim(),
          _dosageController.text.trim(),
          formattedTime,
        );
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        _showSnackBar("Erreur lors de l'enregistrement.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Une erreur inattendue s'est produite.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMedication() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Supprimer le traitement",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          content: const Text(
            "Cette action est irréversible. Voulez-vous vraiment supprimer ce traitement de votre dossier ?",
            style: TextStyle(color: Color(0xFF475569), height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Annuler",
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Supprimer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final medicationProvider = Provider.of<MedicationProvider>(
        context,
        listen: false,
      );
      final bool success = await medicationProvider.deleteMedication(
        widget.id!,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        _showSnackBar("Erreur lors de la suppression.", isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Une erreur inattendue s'est produite.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError
            ? Colors.redAccent.shade700
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildClinicalInfoCard(),
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.close_rounded,
          color: Color(0xFF0F172A),
          size: 28,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _isEditMode ? "Modifier le traitement" : "Ajouter un traitement",
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      centerTitle: true,
      actions: [
        if (_isEditMode)
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent.shade700,
              size: 26,
            ),
            onPressed: _isLoading ? null : _deleteMedication,
          ),
      ],
    );
  }

  Widget _buildClinicalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Informations cliniques",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _nameController,
            label: "Nom du médicament",
            icon: Icons.vaccines_rounded,
            errorMessage: "Le nom du médicament est requis",
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dosageController,
            label: "Posologie (ex: 500mg, 1 cp)",
            icon: Icons.monitor_weight_outlined,
            errorMessage: "La posologie est requise",
          ),
          const SizedBox(height: 16),
          _buildTimePicker(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String errorMessage,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      textCapitalization: textCapitalization,
      maxLength: 100,
      decoration: InputDecoration(
        counterText: "",
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B)),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent.shade700, width: 2),
        ),
      ),
      validator: (String? value) {
        if (value == null || value.trim().isEmpty) {
          return errorMessage;
        }
        return null;
      },
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _isLoading ? null : _pickTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: Color(0xFF64748B)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                    : "Heure de prise",
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTime != null
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF64748B),
                  fontWeight: _selectedTime != null
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMedication,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0052D4),
          disabledBackgroundColor: const Color(0xFF0052D4).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                _isEditMode ? "Mettre à jour" : "Enregistrer le traitement",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
