import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class MembershipTab extends StatelessWidget {
  const MembershipTab({super.key});

  @override
  Widget build(BuildContext context) {
    final membership = context.watch<AuthProvider>().currentMembership;
    if (membership == null) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Current membership',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Text(
          membership.name,
          key: const Key('currentMembershipName'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Included features',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final f in membership.features)
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(f.name),
          ),
      ],
    );
  }
}
