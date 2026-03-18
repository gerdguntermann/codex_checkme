import 'package:flutter_test/flutter_test.dart';
import 'package:checkme/data/models/contact_model.dart';
import 'package:checkme/domain/entities/contact.dart';

void main() {
  const contact = Contact(
    id: 'id1',
    name: 'Anna Müller',
    email: 'anna@example.com',
    phone: '+49123456789',
  );

  group('ContactModel.fromDomain', () {
    test('maps all fields', () {
      final model = ContactModel.fromDomain(contact);
      expect(model.id, contact.id);
      expect(model.name, contact.name);
      expect(model.email, contact.email);
      expect(model.phone, contact.phone);
    });
  });

  group('ContactModel round-trips', () {
    test('fromDomain → toDomain', () {
      expect(ContactModel.fromDomain(contact).toDomain(), contact);
    });

    test('toJson → fromJson → toDomain', () {
      final json = ContactModel.fromDomain(contact).toJson();
      expect(ContactModel.fromJson(json).toDomain(), contact);
    });

    test('null phone survives round-trip', () {
      const noPhone = Contact(id: 'x', name: 'Bob', email: 'b@b.com');
      final json = ContactModel.fromDomain(noPhone).toJson();
      expect(ContactModel.fromJson(json).toDomain().phone, isNull);
    });
  });

  group('ContactModel.toJson', () {
    test('json contains expected keys', () {
      final json = ContactModel.fromDomain(contact).toJson();
      expect(json.keys, containsAll(['id', 'name', 'email', 'phone']));
    });
  });
}
