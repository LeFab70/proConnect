import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../provider/auth_provider.dart';
import '../../services/community_ai_service.dart';
import '../../services/predicthq_service.dart';

enum _ActivitySource {
  proconnectNb,
  predictHq,
}

class ListActivityScreen extends StatefulWidget {
  const ListActivityScreen({super.key});

  @override
  State<ListActivityScreen> createState() => _ListActivityScreenState();
}

class _ListActivityScreenState extends State<ListActivityScreen> {
  final TextEditingController _villeController = TextEditingController();

  List<ActiviteIA> _activities = [];
  bool _isLoading = false;
  _ActivitySource _source = _ActivitySource.proconnectNb;

  // Fabrice | 2026-05-05T05:02:10Z | ProConnectNB = POST /api/activites/suggestions ; Externe = PredictHQ uniquement sur action explicite.
  Future<void> _searchActivities() async {
    final ville = _villeController.text.trim();

    if (ville.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer une ville")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _activities = [];
    });

    try {
      if (_source == _ActivitySource.proconnectNb) {
        final auth = context.read<AuthProvider>();
        if (auth.token == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Connecte-toi pour utiliser les suggestions ProConnectNB.",
                ),
              ),
            );
          }
          return;
        }

        final svc = CommunityAiService();
        final list = await svc.fetchSuggestions(
          token: auth.token!,
          adresse: "$ville, NB, Canada",
        );

        if (!mounted) return;
        setState(() {
          _activities = list;
        });
      } else {
        final activites = await PredictHqService().fetchEventsByCity(ville);

        if (!mounted) return;
        setState(() {
          _activities = activites;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} à "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _villeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activités"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF004E92), Color(0xFF000428)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<_ActivitySource>(
                  segments: const [
                    ButtonSegment<_ActivitySource>(
                      value: _ActivitySource.proconnectNb,
                      label: Text("ProConnectNB"),
                      icon: Icon(Icons.auto_awesome, size: 18),
                    ),
                    ButtonSegment<_ActivitySource>(
                      value: _ActivitySource.predictHq,
                      label: Text("Externe"),
                      icon: Icon(Icons.public, size: 18),
                    ),
                  ],
                  selected: {_source},
                  onSelectionChanged: (Set<_ActivitySource> next) {
                    setState(() => _source = next.first);
                  },
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF004E92);
                      }
                      return Colors.white;
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _source == _ActivitySource.proconnectNb
                      ? "Suggestions via l’API ProConnectNB (session requise)."
                      : "Événements externes PredictHQ — clé PREDICT_HQ_TOKEN dans .env.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _villeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Entrer une ville",
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.1),
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: Colors.white70,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _searchActivities(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _searchActivities,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C6FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _activities.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucune activité",
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final activity = _activities[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.titre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                if (activity.description.isNotEmpty)
                                  Text(
                                    activity.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),

                                const SizedBox(height: 8),

                                Text(
                                  "📍 ${activity.lieu}",
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                Text(
                                  "📅 ${_formatDate(activity.dateHeure)}",
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                Text(
                                  "🏷 ${activity.categorie}",
                                  style: const TextStyle(color: Colors.white70),
                                ),

                                Text(
                                  "⭐ Pertinence : ${activity.scorePertinence.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
