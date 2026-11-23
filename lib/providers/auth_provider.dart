import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:membership_app/models/feature.dart';
import 'package:membership_app/models/membership.dart';
import 'package:membership_app/models/users_profile.dart';

import '../services/membership_repository.dart';

class AuthProvider extends ChangeNotifier {
  final MembershipRepository _repo;

  AuthProvider(this._repo);

  bool _initialized = false;
  List<Membership> _memberships = [];
  List<UsersProfile> _users = [];
  UsersProfile? _currentUser;

  bool get isInitialized => _initialized;
  bool get isSignedIn => _currentUser != null;
  UsersProfile? get currentUser => _currentUser;
  List <Membership> get memberships => List.unmodifiable(_memberships);

  Membership? get currentMembership =>
      _currentUser == null ? null : membershipById(_currentUser!.membershipId);

  List<Feature> get currentFeatures => currentMembership?.features ?? const [];

  List<Membership> get upgradedOptions {
    final current = currentMembership;
    if (current == null) return const [];
    return _memberships.where((m) => m.rank > current.rank).toList();
  }

  bool get isOnHighestTier => isSignedIn && upgradedOptions.isEmpty;

  Membership? membershipById(String id){
    for (final m in _memberships){
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> init() async{
    _memberships = await _repo.loadMemberships();
    await _repo.seedIfNeeded();
    _users = _repo.loadUsers();
    final email = _repo.sessionEmail;
    if (email!= null){
      _currentUser = _findByEmail(email);
    }
    if (_currentUser == null) {
      await _repo.clearSession();
    }
      _initialized = true;
      notifyListeners();
  }

  Future<String?> signIn(String email) async {
    final user = _findByEmail(email);
    if (user == null) {
      return 'No profile found for that email. Please sign up.';
    }
    _currentUser = user;
    await _repo.setSession(user.email);
    notifyListeners();
    return null;
  }


  Future<String?> signUp({
    required String name,
    required String email,
    required String membershipId,
}) async {
    if (name.trim().isEmpty){
      return 'Please enter your name.';
    }
    if (!_isValidEmail(email)){
      return 'Please enter a valid email address.';
    }
    if(_findByEmail(email) != null){
      return 'That email address is already registered.';
    }
    if(membershipById(membershipId) == null){
      return'Please choose a membership';
    }

    final user = UsersProfile(
        id: await _repo.allocateUserId(_users),
        name: name.trim(),
        email: email.trim(),
        membershipId: membershipId,
    );
    _users = [..._users, user];
    await _repo.saveUsers(_users);
    _currentUser = user;
    await _repo.setSession(user.email);
    notifyListeners();
    return null;
  }

  Future<String?> upgrade(String membershipId) async{
    final user = _currentUser;
    if (user == null) return 'You are not signed in.';
    if(!upgradedOptions.any((m) => m.id == membershipId)) {
      return 'That memebership is not an upgrade from your current tier.';
    }
    final updated = user.copyWith(membershipId: membershipId);
    _users = [for (final u in _users) u.id == user.id ? updated : u];
    await _repo.saveUsers(_users);
    _currentUser = updated;
    notifyListeners();
    return null;
  }

  Future<void> signOut() async{
    _currentUser = null;
    await _repo.clearSession();
    notifyListeners();
  }

  Future<void> deleteCurrentProfile() async{
    final user = _currentUser;
    if (user == null) return;
    _users = _users.where((u) => u.id != user.id).toList();
    await _repo.saveUsers(_users);
    await signOut();
  }

  UsersProfile? _findByEmail(String email){
    final key = normalizeEmail(email);
    for ( final u in _users){
      if (normalizeEmail(u.email) == key) return u;
    }
    return null;
  }

  static bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

}