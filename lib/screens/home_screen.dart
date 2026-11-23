import 'package:flutter/material.dart';
import 'package:membership_app/providers/auth_provider.dart';
import 'package:membership_app/screens/tabs/home_tab.dart';
import 'package:membership_app/screens/tabs/membership_tab.dart';
import 'package:membership_app/screens/tabs/upgrade_tab.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int _index = 0;

  static const _titles = ['Home', 'Membership', 'Upgrade Membership'];

  Future<void> _confirmDelete() async{
    final auth = context.read<AuthProvider>();
    final ok = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete profile?'),
          content: const Text(
            'Your profile will be removed from this device. You will need to sign up again to use the app.'
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('cancel'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
            ),
          ],
        ),
    );
    if (ok == true){
      await auth.deleteCurrentProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          PopupMenuButton<String>(
            key: const Key('accountMenu'),
              onSelected: (value) {
                if (value == 'signOut') auth.signOut();
                if (value == 'delete') _confirmDelete();
              },
            itemBuilder: (_) =>[
              PopupMenuItem(
                enabled: false,
                child: Text(auth.currentUser?.email ?? ''),
              ),
              const PopupMenuItem(value: 'signOut', child: Text('Sign out')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete profile'),
              ),
            ],
          )
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [HomeTab(), MembershipTab(), UpgradeTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.card_membership),
            label: 'Membership',
          ),
          NavigationDestination(icon: Icon(Icons.upgrade), label: 'Upgrade'),
        ],
      ),
    );
  }
}
