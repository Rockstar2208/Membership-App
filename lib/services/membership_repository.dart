import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/membership.dart';
import '../models/users_profile.dart';

typedef AssetLoader = Future<String> Function(String path);

class MembershipRepository {
  static const _seededKey = 'seeded';
  static const _usersKey = 'users';
  static const _sessionKey = 'currentUserEmail';
  static const _nextUserNumberKey = 'nextUserNumber';

  static const _idPrefix = 'usr_';
  static const _firstUserNumber = 1001;
  static final _idPattern = RegExp(r'^usr_(\d+)$');

  static const usersAsset = 'assets/data/users.json';
  static const membershipsAsset = 'assets/data/memberships.json';

  final SharedPreferences _prefs;
  final AssetLoader _loadAsset;

  MembershipRepository(this._prefs, {AssetLoader? loadAsset})
      : _loadAsset = loadAsset ?? rootBundle.loadString;

  Future<List<Membership>> loadMemberships() async {
    final list = _asList(
      jsonDecode(await _loadAsset(membershipsAsset)),
      'memberships',
    );
    final memberships = <Membership>[
      for (var i = 0; i < list.length; i++)
        Membership.fromJson(Map<String, dynamic>.from(list[i] as Map), i),
    ];
    memberships.sort((a, b) => a.rank.compareTo(b.rank));
    return memberships;
  }

  Future<void> seedIfNeeded() async {
    if (_prefs.getBool(_seededKey) ?? false) return;
    final list = _asList(jsonDecode(await _loadAsset(usersAsset)), 'users');
    final users = list
        .map((e) => UsersProfile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    await saveUsers(users);
    await _prefs.setInt(_nextUserNumberKey, _numberAfter(users));
    await _prefs.setBool(_seededKey, true);
  }

  Future<String> allocateUserId(List<UsersProfile> existingUsers) async {
    final next =
        _prefs.getInt(_nextUserNumberKey) ?? _numberAfter(existingUsers);
    await _prefs.setInt(_nextUserNumberKey, next + 1);
    return '$_idPrefix$next';
  }

  static int _numberAfter(List<UsersProfile> users) {
    var highest = _firstUserNumber - 1;
    for (final u in users) {
      final match = _idPattern.firstMatch(u.id);
      if (match == null) continue;
      final n = int.parse(match.group(1)!);
      if (n > highest) highest = n;
    }
    return highest + 1;
  }

  List<UsersProfile> loadUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => UsersProfile.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveUsers(List<UsersProfile> users) => _prefs.setString(
    _usersKey,
    jsonEncode(users.map((u) => u.toJson()).toList()),
  );

  String? get sessionEmail => _prefs.getString(_sessionKey);
  Future<void> setSession(String email) => _prefs.setString(_sessionKey, email);
  Future<void> clearSession() => _prefs.remove(_sessionKey);

  static List _asList(dynamic decoded, String key) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded[key] is List) return decoded[key] as List;
    throw FormatException('Expected a list or an object with "$key"');
  }
}
