import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
  });

  Contact copyWith({String? id, String? name, String? email, String? phone}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone];
}
