import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String result = "Appuyer pour tester l'API";
  bool loading = false;

  Future<void> callApi() async {
    setState(() => loading = true);

    try {
      final api = Api();

      final response = await api.getUser(1); // 🔥 ID requis

      if (response == null) {
        setState(() {
          result = "Erreur : aucune donnée reçue";
        });
      } else {
        setState(() {
          result = const JsonEncoder.withIndent('  ').convert(response);
        });
      }
    } catch (e) {
      setState(() {
        result = "Erreur API : $e";
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test API")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: loading
              ? const CircularProgressIndicator()
              : SingleChildScrollView(
                  child: SelectableText(
                    result,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: callApi,
        child: const Icon(Icons.send),
      ),
    );
  }
}
