import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../global/custom_input.dart';
import '../global/custom_button.dart';

class AddRappelForm extends StatefulWidget {
  final Function(String type, DateTime dateHeure, bool isMed) onSubmit;

  const AddRappelForm({super.key, required this.onSubmit});

  @override
  State<AddRappelForm> createState() => _AddRappelFormState();
}

class _AddRappelFormState extends State<AddRappelForm> {
  final _typeController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Stocke le jour
  TimeOfDay _selectedTime = TimeOfDay.now(); // Stocke l'heure
  bool _isMed = true;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // On ne peut pas planifier dans le passé
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF4A3AFF)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() {
    if (_typeController.text.isEmpty) return;

    final DateTime dateHeureComplete = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSubmit(_typeController.text, dateHeureComplete, _isMed);
    _typeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CustomInput(
              controller: _typeController,
              label: "Nom du rappel",
              icon: Icons.notifications_active,
            ),
            const SizedBox(height: 15),

            _buildPickerTile(
              icon: Icons.calendar_month,
              label: "Date :",
              value: DateFormat('dd/MM/yyyy').format(_selectedDate),
              onTap: _pickDate,
            ),
            
            const SizedBox(height: 10),

            _buildPickerTile(
              icon: Icons.access_time,
              label: "Heure :",
              value: _selectedTime.format(context),
              onTap: _pickTime,
            ),

            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text("Médicament"),
                  selected: _isMed,
                  onSelected: (_) => setState(() => _isMed = true),
                ),
                ChoiceChip(
                  label: const Text("Rendez-vous"),
                  selected: !_isMed,
                  onSelected: (_) => setState(() => _isMed = false),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(text: "Enregistrer le rappel", onPressed: _submit),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF4A3AFF), size: 20),
                const SizedBox(width: 10),
                Text(label),
              ],
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}