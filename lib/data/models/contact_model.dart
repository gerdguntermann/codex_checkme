import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/contact.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  final String id;
  final String name;
  final String email;

  const ContactModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) =>
      _$ContactModelFromJson(json);

  Map<String, dynamic> toJson() => _$ContactModelToJson(this);

  factory ContactModel.fromDomain(Contact contact) => ContactModel(
        id: contact.id,
        name: contact.name,
        email: contact.email,
      );

  Contact toDomain() => Contact(id: id, name: name, email: email);
}
