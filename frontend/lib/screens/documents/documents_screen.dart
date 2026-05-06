import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/tr_text.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final TextEditingController _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isConnected = false;
  String? _error;

  // =========================
  // VERIFY CODE
  // =========================
  void _verifyCode() async {
    final code = _codeController.text.replaceAll('-', '');

    if (code.length != 6) {
      setState(() => _error = "Code invalide");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    FocusScope.of(context).unfocus();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 🔥 SIMULATION (remplacer par API plus tard)
    if (code == "123456") {
      setState(() {
        _isConnected = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = "Code incorrect";
      });
    }
  }

  // =========================
  // RESET CONNECTION
  // =========================
  void _disconnect() {
    setState(() {
      _isConnected = false;
      _codeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const TrText(
          "Dossier Médical",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const TrText(
            "Mes Informations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 16),

          _buildDocCard(
            "Analyses",
            "Labo Central - Hier",
            Icons.science,
            Colors.blue,
          ),

          _buildDocCard(
            "Ordonnances",
            "Dr. Martin - 12 Oct.",
            Icons.description,
            Colors.purple,
          ),

          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 24),

          const TrText(
            "Espace Proche Aidant",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: _isConnected ? _buildPatientData() : _buildCodeForm(),
          ),
        ],
      ),
    );
  }

  // =========================
  // DOC CARD
  // =========================
  Widget _buildDocCard(String t, String s, IconData i, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(i, color: c),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(s, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // CODE FORM
  // =========================
  Widget _buildCodeForm() {
    return Container(
      key: const ValueKey(1),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const TrText(
            "Entrez le code de votre proche :",
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 7,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              if (value.length == 6) {
                _verifyCode();
              }
            },
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: InputDecoration(
              counterText: "",
              hintText: "123456",
              errorText: _error,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const TrText(
                    "Lier le dossier",
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  // =========================
  // CONNECTED STATE
  // =========================
  Widget _buildPatientData() {
    return Container(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 2),
      ),
      child: Column(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              "Dossier connecté",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Connexion réussie"),
          ),

          const Divider(),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text("Médicaments"),
                  Text("2/3",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              Column(
                children: [
                  Text("Activité"),
                  Text("4500 pas",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextButton(
            onPressed: _disconnect,
            child: const TrText("Changer de patient"),
          )
        ],
      ),
    );
  }
}