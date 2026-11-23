import 'package:flutter/material.dart';
import 'package:membership_app/providers/auth_provider.dart';
import 'package:membership_app/screens/home_screen.dart';
import 'package:membership_app/screens/sign_in_screen.dart';
import 'package:membership_app/services/membership_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final auth = AuthProvider(MembershipRepository(prefs));
  await auth.init();
  runApp(
    ChangeNotifierProvider.value(value: auth, child: const MembershipApp()),
  );
}

class MembershipApp extends StatelessWidget{
  const MembershipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Membership App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) =>
            auth.isSignedIn ? const HomeScreen() : const SignInScreen(),
      ),
    );
  }
}




