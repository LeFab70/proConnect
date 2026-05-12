import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDemoSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('demo_medications_status');

  static Future<void> saveMedicationStatus({
    required String medicationId,
    required String status,
  }) async {
    print("FIREBASE SAVE START");

    await _collection.doc(medicationId).set({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print("FIREBASE SAVE DONE");
  }

  static Future<String?> getMedicationStatus(String medicationId) async {
    final doc = await _collection.doc(medicationId).get();

    if (!doc.exists) return null;

    final data = doc.data();

    return data?['status']?.toString();
  }
  static Future<void> deleteMedicationStatus({
  required String medicationId,
}) async {
  await _collection.doc(medicationId).delete();
}
}
