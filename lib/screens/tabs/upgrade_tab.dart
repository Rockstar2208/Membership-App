import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/membership.dart';
import '../../providers/auth_provider.dart';

class UpgradeTab extends StatelessWidget {
  const UpgradeTab({super.key});

  Future<void> _confirmUpgrade(BuildContext context, Membership target) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Upgrade to ${target.name}?'),
        content: Text(
          'You will move from ${auth.currentMembership?.name} to ${target.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final error = await auth.upgrade(target.id);
    messenger.showSnackBar(
      SnackBar(content: Text(error ?? 'You are now on ${target.name}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isOnHighestTier) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            "You're on ${auth.currentMembership?.name}, our highest tier. There's nothing to upgrade to.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final m in auth.upgradedOptions)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  for (final f in m.features)
                    Text('• ${f.name}', key: ValueKey('${m.id}-${f.id}')),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () => _confirmUpgrade(context, m),
                      child: Text('Upgrade to ${m.name}'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
