import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/activity.dart';
import '../../provider/activity_provider.dart';
import '../../provider/auth_provider.dart';

class FavoriteActivitiesScreen extends StatelessWidget {
  const FavoriteActivitiesScreen({super.key});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year} à "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final activity = context.watch<ActivityProvider>();

    final items = activity.favorites(auth);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoris"),
      ),
      body: items.isEmpty
          ? const Center(child: Text("Aucun favori"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final a = items[index];
                return _FavCard(
                  activity: a,
                  date: _formatDate(a.dateHeure),
                );
              },
            ),
    );
  }
}

class _FavCard extends StatelessWidget {
  final ActiviteIA activity;
  final String date;

  const _FavCard({required this.activity, required this.date});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.titre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: "Retirer des favoris",
                onPressed: () => context
                    .read<ActivityProvider>()
                    .toggleFavorite(auth, activity),
                icon: const Icon(Icons.star),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (activity.description.isNotEmpty) Text(activity.description),
          const SizedBox(height: 8),
          Text(
            "$date • ${activity.lieu}",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

