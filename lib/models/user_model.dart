 
 import 'user_role.dart';

 class USerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  const USerModel ({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });
 }
