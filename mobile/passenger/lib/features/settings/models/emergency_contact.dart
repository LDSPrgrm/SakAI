/// Emergency contact model.
class EmergencyContactModel {
  const EmergencyContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
  });

  final String id;
  final String name;
  final String phone;
  final String relationship;

  EmergencyContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
  }) {
    return EmergencyContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relationship': relationship,
    };
  }

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      relationship: json['relationship'] as String,
    );
  }
}
