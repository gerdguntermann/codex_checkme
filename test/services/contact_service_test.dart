import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/data/contact_service.dart';
import 'package:checkme/domain/entities/contact.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ContactService service;
  const uid = 'test_user';

  const baseContact = Contact(
    id: '',
    name: 'Anna Müller',
    email: 'anna@example.com',
    phone: '+49123456789',
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ContactService(firestore, const Uuid());
  });

  group('ContactService.getContacts', () {
    test('returns empty list when no contacts', () async {
      expect(await service.getContacts(uid), isEmpty);
    });

    test('returns contacts after add', () async {
      await service.addContact(uid, baseContact);
      final contacts = await service.getContacts(uid);
      expect(contacts, hasLength(1));
      expect(contacts.first.name, 'Anna Müller');
    });
  });

  group('ContactService.addContact', () {
    test('assigns a UUID when id is empty', () async {
      final created = await service.addContact(uid, baseContact);
      expect(created.id, isNotEmpty);
    });

    test('keeps provided id when not empty', () async {
      final withId = baseContact.copyWith(id: 'fixed-id');
      final created = await service.addContact(uid, withId);
      expect(created.id, 'fixed-id');
    });

    test('persists to Firestore', () async {
      final created = await service.addContact(uid, baseContact);
      final snap = await firestore
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .doc(created.id)
          .get();
      expect(snap.exists, isTrue);
      expect(snap.data()!['email'], 'anna@example.com');
    });
  });

  group('ContactService.updateContact', () {
    test('updates existing contact', () async {
      final created = await service.addContact(uid, baseContact);
      final updated = created.copyWith(name: 'Anna Schmidt');
      await service.updateContact(uid, updated);

      final contacts = await service.getContacts(uid);
      expect(contacts.first.name, 'Anna Schmidt');
    });
  });

  group('ContactService.deleteContact', () {
    test('removes contact from Firestore', () async {
      final created = await service.addContact(uid, baseContact);
      await service.deleteContact(uid, created.id);

      final contacts = await service.getContacts(uid);
      expect(contacts, isEmpty);
    });

    test('deleting non-existent contact does not throw', () async {
      await expectLater(
        service.deleteContact(uid, 'non-existent-id'),
        completes,
      );
    });
  });

  group('ContactService user isolation', () {
    test('contacts of different users do not mix', () async {
      await service.addContact('user_a', baseContact);
      final contactsB = await service.getContacts('user_b');
      expect(contactsB, isEmpty);
    });
  });
}
