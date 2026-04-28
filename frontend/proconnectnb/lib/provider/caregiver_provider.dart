import 'package:flutter/material.dart';

class Caregiver {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isConnectedAccount; // True si lié par le code secret

  Caregiver({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.isConnectedAccount = false,
  });
}

class CaregiverProvider with ChangeNotifier {
  final List<Caregiver> _caregivers = [
    Caregiver(
      id: '1',
      name: 'Dr. Tremblay',
      phone: '+1 555-0198',
      relation: 'Médecin Traitant',
      isConnectedAccount: true,
    ),
  ];

  List<Caregiver> get caregivers => List.unmodifiable(_caregivers);

  void addCaregiver(String name, String phone, String relation) {
    _caregivers.add(
      Caregiver(
        id: DateTime.now().toString(),
        name: name,
        phone: phone,
        relation: relation,
      ),
    );
    notifyListeners();
  }
}
