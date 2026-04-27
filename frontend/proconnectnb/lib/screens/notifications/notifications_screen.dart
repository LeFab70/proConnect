import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Fausses données de notifications pour la démo
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Rappel de Médicament",
        "message": "Il est l'heure de prendre votre Paracétamol (1000mg).",
        "time": "Il y a 10 min",
        "icon": Icons.vaccines_rounded,
        "color": const Color(0xFF0052D4),
        "isNew": true,
      },
      {
        "title": "Objectif atteint ! 🎉",
        "message": "Félicitations, vous avez dépassé vos 5000 pas aujourd'hui.",
        "time": "Il y a 2 heures",
        "icon": Icons.directions_walk_rounded,
        "color": const Color(0xFF10B981),
        "isNew": true,
      },
      {
        "title": "Nouveau document",
        "message": "Le Dr. Tremblay a ajouté vos résultats d'analyses.",
        "time": "Hier",
        "icon": Icons.description_rounded,
        "color": const Color(0xFF8E2DE2),
        "isNew": false,
      },
      {
        "title": "Liaison réussie",
        "message":
            "Votre dossier est maintenant partagé avec votre proche aidant.",
        "time": "Hier",
        "icon": Icons.diversity_1_rounded,
        "color": const Color(0xFFF2994A),
        "isNew": false,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF0052D4)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Toutes les notifications sont marquées comme lues.",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: notif["isNew"] ? Colors.white : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: notif["isNew"]
                  ? Border.all(color: notif["color"].withOpacity(0.3), width: 1)
                  : null,
              boxShadow: notif["isNew"]
                  ? [
                      const BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notif["color"].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notif["icon"], color: notif["color"], size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif["title"],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notif["isNew"]
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (notif["isNew"])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notif["message"],
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                          fontWeight: notif["isNew"]
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notif["time"],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
