import 'package:membership_app/models/feature.dart';

class Membership {
  final String id;
  final String name;
  final List<Feature> features;
  final int rank;

  const Membership({
    required this.id,
    required this.name,
    required this.features,
    required this.rank
  });

  factory Membership.fromJson(Map<String, dynamic> json, int index) => Membership(
    id: json['id'].toString(),
    name: json['name'].toString(),
    features: (json['features'] as List)
      .map((f) => Feature.fromJson(f as Map<String, dynamic>))
      .toList(),
    rank: index,
  );
}