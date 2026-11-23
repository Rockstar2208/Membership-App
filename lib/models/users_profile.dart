class UsersProfile {
  final String id;
  final String name;
  final String email;
  final String membershipId;

  const UsersProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.membershipId
  });

  UsersProfile copyWith({String? membershipId}) => UsersProfile(
      id: id,
      name: name,
      email: email,
      membershipId: membershipId ?? this.membershipId
  );

  factory UsersProfile.fromJson(Map<String, dynamic> json) => UsersProfile(
      id: json['id'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      membershipId: json['membershipId'].toString()
  );

  Map<String, dynamic> toJson() =>{
    'id' : id,
    'name' : name,
    'email' : email,
    'membershipId' : membershipId
  };
}

String normalizeEmail (String email) => email.trim().toLowerCase();