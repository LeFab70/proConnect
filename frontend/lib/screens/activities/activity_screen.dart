import 'package:flutter/material.dart';
import '../../provider/settings_provider.dart';
import '../../widgets/app_background.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/provider/activity_provider.dart';
import '/widgets/tr_text.dart';

class ActivitySettingsScreen extends StatefulWidget {
  const ActivitySettingsScreen({super.key});

  @override
  State<ActivitySettingsScreen> createState() => _ActivitySettingsScreenState();
}

class _ActivitySettingsScreenState extends State<ActivitySettingsScreen> {
  late TextEditingController _stepController;

  @override
  void initState() {
    super.initState();
    final currentGoal = context.read<ActivityProvider>().todayActivity.stepGoal;
    _stepController = TextEditingController(text: currentGoal.toString());
  }

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final newGoal = int.tryParse(_stepController.text);
    if (newGoal != null && newGoal > 0) {
      context.read<ActivityProvider>().updateStepGoal(newGoal);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const TrText(
            "Objectif mis à jour !",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(24),
        ),
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppBackground.scaffoldColor(settings.isDarkMode),
      body: AppBackground(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIntroCard(),
                          const SizedBox(height: 16),
                          _buildStepGoalCard(),
                          const SizedBox(height: 16),
                          _buildTipsCard(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),

          const Text(
            "Réglages Activité",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),

          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Color(0xFF34D399),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Objectif Quotidien",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Définissez votre nombre de pas cible par jour.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepGoalCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000428).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004E92).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF4A9FE8).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFF7DC4FF),
                  size: 17,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Nombre de pas",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          Divider(color: Colors.white.withValues(alpha: 0.08), height: 24),

          // Champ + bouton
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.directions_walk_rounded,
                      color: const Color(0xFF34D399).withValues(alpha: 0.8),
                      size: 20,
                    ),
                    suffixText: "pas",
                    suffixStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF34D399),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _handleSave,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF34D399), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      (Icons.wb_sunny_outlined, "Commencez par 5 000 pas/jour si vous débutez"),
      (
        Icons.trending_up_rounded,
        "L'objectif recommandé est de 10 000 pas/jour",
      ),
      (Icons.favorite_border_rounded, "30 min de marche = environ 3 000 pas"),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 15,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                "Le saviez-vous ?",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.6),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tip.$1, size: 15, color: Colors.white.withValues(alpha: 0.3)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip.$2,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.45),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
