import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  final String id;
  final String name;
  final String email;

  const Contact({
    required this.id,
    required this.name,
    required this.email,
  });

  Contact copyWith({String? id, String? name, String? email}) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id, name, email];
}
