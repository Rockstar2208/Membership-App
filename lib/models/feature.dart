class Feature {
  final String id;
  final String name;

  const Feature({required this.id, required this.name});

  factory Feature.fromJson(Map<String, dynamic> json) =>
      Feature(id: json['id'] , name: json['name'] as String);
}