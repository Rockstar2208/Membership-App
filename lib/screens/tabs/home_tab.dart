import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/feature.dart';
import '../../providers/auth_provider.dart';
import '../feature_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final features = auth.currentFeatures;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hi, ${user?.name ?? ''}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text('Your ${auth.currentMembership?.name ?? ''} features'),
        const SizedBox(height: 16),
        for (final feature in features)
          Card(
            key: ValueKey(feature.id),
            child: ListTile(
              leading: Icon(_iconFor(feature)),
              title: Text(feature.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FeatureScreen(feature: feature),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static IconData _iconFor(Feature feature) => switch (feature.id) {
    'browse_catalogue' => Icons.menu_book_outlined,
    'starter_guides' => Icons.school_outlined,
    'member_offers' => Icons.local_offer_outlined,
    'priority_support' => Icons.support_agent,
    _ => Icons.star_outline,
  };
}
