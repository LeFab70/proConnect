import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../models/partage_suivi.dart';
import 'auth_provider.dart';

class PartageProvider extends ChangeNotifier {
  final Api _api = Api();

  // =========================
  // AÎNÉ → AJOUT PROCHE AIDANT
  // =========================
  Future<bool> aineAjouteProche({
    required int aineId,
    required int procheId,
    required AuthProvider auth,
  }) async {
    if (auth.token == null) return false;

    final partage = PartageSuivi(
      id: 0,
      autorisation: "Suivi Complet",
      aineId: aineId,
      procheAidantId: procheId,
    );

    bool success = await _api.upsertPartage(partage, auth.token!);

    if (success) notifyListeners();

    return success;
  }

  // =========================
  // AIDANT → INVITE AÎNÉ
  // =========================
  Future<bool> procheInviteAine({
    required int aineId,
    required int procheAidantId,
    required AuthProvider auth,
  }) async {
    if (auth.token == null) return false;

    final partage = PartageSuivi(
      id: 0,
      autorisation: "Collaboration",
      aineId: aineId,
      procheAidantId: procheAidantId,
    );

    bool success = await _api.upsertPartage(partage, auth.token!);

    if (success) notifyListeners();

    return success;
  }
}