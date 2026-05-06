import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../global/custom_input.dart';
import '../global/custom_button.dart';

class AddAppointmentForm extends StatefulWidget {
  final Function(DateTime dateHeure, String lieu, String docteur, String? notes) onSubmit;

  const AddAppointmentForm({super.key, required this.onSubmit});

  @override
  State<AddAppointmentForm> createState() => _AddAppointmentFormState();
}

class _AddAppointmentFormState extends State<AddAppointmentForm> {
  final _docteurController = TextEditingController();
  final _lieuController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _submit() {
    if (_docteurController.text.isEmpty || _lieuController.text.isEmpty) return;

    final DateTime fullDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    widget.onSubmit(
      fullDateTime,
      _lieuController.text,
      _docteurController.text,
      _notesController.text.isEmpty ? null : _notesController.text,
    );

    _docteurController.clear();
    _lieuController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          CustomInput(controller: _docteurController, label: "Nom du Docteur", icon: Icons.person),
          const SizedBox(height: 10),
          CustomInput(controller: _lieuController, label: "Lieu / Clinique", icon: Icons.location_on),
          const SizedBox(height: 10),
          CustomInput(controller: _notesController, label: "Notes (Optionnel)", icon: Icons.note),
          const SizedBox(height: 15),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (d != null) setState(() => _selectedDate = d);
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: Text(DateFormat('dd/MM/yy').format(_selectedDate)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: _selectedTime);
                    if (t != null) setState(() => _selectedTime = t);
                  },
                  icon: const Icon(Icons.access_time),
                  label: Text(_selectedTime.format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          CustomButton(text: "Programmer le rendez-vous", onPressed: _submit),
        ],
      ),
    );
  }
}