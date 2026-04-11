import 'package:sakai_api_client/sakai_api_client.dart';

/// Domain User model — stable wrapper around the generated [UserProfile].
class DomainUser {
  final String id;
  final String name;
  final String email;
  final String role;

  DomainUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory DomainUser.fromApi(UserProfile u) => DomainUser(
        id: u.id,
        name: u.name,
        email: u.email,
        role: u.role.name,
      );
}
