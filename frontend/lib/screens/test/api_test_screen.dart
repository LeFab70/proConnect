import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/auth_provider.dart';
import '../../services/api.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String result = "Appuyer sur le bouton pour tester la connexion Azure";
  bool loading = false;

  Future<void> callApi() async {
    setState(() {
      loading = true;
      result = "Connexion en cours...";
    });

    try {
      final api = Api();
      final auth = context.read<AuthProvider>();
      final token = auth.token;

      // Fabrice | 2026-05-05T04:47:29Z | /api/users/{id} exige Authorization Bearer.
      if (token == null || token.isEmpty) {
        setState(() {
          result =
              "❌ Connecte-toi d’abord : GET /api/users nécessite un JWT.\n\n"
              "Utilise un compte seed puis rouvre cet écran.";
        });
        return;
      }

      // On teste la récupération d'un utilisateur (id 1 = souvent présent après seed)
      final response = await api.getUser(1, token);

      if (response == null) {
        setState(() {
          result =
              "❌ Échec : Le serveur a renvoyé une erreur (404 ou 401).\n\n"
              "Vérifie :\n1. Si l’utilisateur id=1 existe en base.\n"
              "2. Si le token est encore valide.";
        });
      } else {
        setState(() {
          // Formatage JSON propre pour l'affichage
          result =
              "✅ Succès !\n\n${const JsonEncoder.withIndent('  ').convert(response)}";
        });
      }
    } catch (e) {
      setState(() {
        result = "⚠️ Erreur Exception :\n$e";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Debug : Test API Azure"),
        backgroundColor: const Color(0xFF001F3F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Résultat de la requête :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: SelectableText(
                          result,
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Courier', // Style code
                            color: result.contains("❌") || result.contains("⚠️")
                                ? Colors.red.shade800
                                : Colors.black87,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: loading ? null : callApi,
              icon: const Icon(Icons.refresh),
              label: const Text("RETESTER LA CONNEXION"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: const Color(0xFF4A3AFF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
