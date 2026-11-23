import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:membership_app/providers/auth_provider.dart';
import 'package:membership_app/services/membership_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AuthProvider> launchApp() async {
  final prefs = await SharedPreferences.getInstance();
  final repo = MembershipRepository(
    prefs,
    loadAsset: (p) => File(p).readAsString(),
  );
  final auth = AuthProvider(repo);
  await auth.init();
  return auth;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('preloaded users can sign in and see their tier features', () async {
    final auth = await launchApp();
    expect(await auth.signIn('naledi.mokoena@example.com'), isNull);
    expect(auth.currentMembership!.id, 'starter');
    expect(auth.currentFeatures.map((f) => f.id), [
      'browse_catalogue',
      'starter_guides',
    ]);
    expect(auth.upgradedOptions.map((m) => m.id), ['plus', 'premium']);

    await auth.signIn('thabo.dlamini@example.com');
    expect(auth.currentFeatures.map((f) => f.name), [
      'Browse Catalogue',
      'Member Offers',
    ]);

    await auth.signIn('aisha.jacobs@example.com');
    expect(auth.isOnHighestTier, isTrue);
    expect(auth.currentFeatures.map((f) => f.id), contains('priority_support'));
  });

  test('sign-up rejects duplicate emails, ignoring case and spaces', () async {
    final auth = await launchApp();
    final error = await auth.signUp(
      name: 'Dup',
      email: '  NALEDI.mokoena@example.com ',
      membershipId: 'plus',
    );
    expect(error, isNotNull);

    expect(
      await auth.signUp(
        name: 'New',
        email: 'new@example.com',
        membershipId: 'plus',
      ),
      isNull,
    );
    expect(auth.currentMembership!.id, 'plus');
  });

  test(
    'upgrade survives sign-out and restart, other users unaffected',
        () async {
      var auth = await launchApp();
      await auth.signIn('naledi.mokoena@example.com');
      expect(await auth.upgrade('premium'), isNull);
      await auth.signOut();

      auth = await launchApp();
      expect(auth.isSignedIn, isFalse);
      await auth.signIn('naledi.mokoena@example.com');
      expect(auth.currentMembership!.id, 'premium');
      expect(auth.currentFeatures.map((f) => f.id), [
        'browse_catalogue',
        'priority_support',
      ]);
      await auth.signIn('lerato.nkosi@example.com');
      expect(auth.currentMembership!.id, 'starter');
    },
  );

  test('cannot downgrade or "upgrade" to the same tier', () async {
    final auth = await launchApp();
    await auth.signIn('thabo.dlamini@example.com');
    expect(await auth.upgrade('starter'), isNotNull);
    expect(await auth.upgrade('plus'), isNotNull);
  });

  test(
    'deleted profiles stay deleted after restart and are not re-seeded',
        () async {
      var auth = await launchApp();
      for (final email in [
        'naledi.mokoena@example.com',
        'lerato.nkosi@example.com',
        'thabo.dlamini@example.com',
        'sipho.khumalo@example.com',
        'aisha.jacobs@example.com',
      ]) {
        await auth.signIn(email);
        await auth.deleteCurrentProfile();
        expect(auth.isSignedIn, isFalse);
      }

      auth = await launchApp();
      expect(await auth.signIn('naledi.mokoena@example.com'), isNotNull);
      expect(await auth.signIn('aisha.jacobs@example.com'), isNotNull);
    },
  );

  test('deleting one profile keeps the others', () async {
    var auth = await launchApp();
    await auth.signIn('lerato.nkosi@example.com');
    await auth.deleteCurrentProfile();

    auth = await launchApp();
    expect(await auth.signIn('lerato.nkosi@example.com'), isNotNull);
    expect(await auth.signIn('thabo.dlamini@example.com'), isNull);
  });

  test('new users get the next usr_ id after the seeded ones', () async {
    final auth = await launchApp();
    await auth.signUp(
      name: 'Frank Ocean',
      email: 'frank.ocean@example.com',
      membershipId: 'plus',
    );
    expect(auth.currentUser!.id, 'usr_1006');
    await auth.signUp(
      name: 'Lesego Makwele',
      email: 'Lesego.makwele@example.com',
      membershipId: 'starter',
    );
    expect(auth.currentUser!.id, 'usr_1007');
  });

  test('deleted ids are never reused, even after a restart', () async {
    var auth = await launchApp();
    await auth.signUp(
      name: 'Frank Ocean',
      email: 'frank.ocean@example.com',
      membershipId: 'plus',
    );
    expect(auth.currentUser!.id, 'usr_1006');
    await auth.deleteCurrentProfile();

    auth = await launchApp();
    await auth.signUp(
      name: 'Frank Ocean',
      email: 'frank.ocean@example.com',
      membershipId: 'plus',
    );
    expect(auth.currentUser!.id, 'usr_1007');
  });
}
