import 'package:checkme/core/utils/app_logger.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/firestore_constants.dart';
import '../domain/entities/contact.dart';
import 'models/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid;

  ContactService(this._firestore, this._uuid);

  CollectionReference<Map<String, dynamic>> _ref(String userId) => _firestore
      .collection(FirestoreConstants.usersCollection)
      .doc(userId)
      .collection(FirestoreConstants.contactsCollection);

  Future<List<Contact>> getContacts(String userId) async {
    log('getContacts – querying', name: 'ContactService');
    final snapshot = await _ref(userId).get();
    final contacts = snapshot.docs
        .map((doc) => ContactModel.fromJson(doc.data()).toDomain())
        .toList();
    log('getContacts – ${contacts.length} found', name: 'ContactService');
    return contacts;
  }

  Future<Contact> addContact(String userId, Contact contact) async {
    final id = contact.id.isEmpty ? _uuid.v4() : contact.id;
    final withId = contact.copyWith(id: id);
    log('addContact – writing id=$id', name: 'ContactService');
    await _ref(userId).doc(id).set(ContactModel.fromDomain(withId).toJson());
    return withId;
  }

  Future<Contact> updateContact(String userId, Contact contact) async {
    log('updateContact – id=${contact.id}', name: 'ContactService');
    await _ref(userId).doc(contact.id).update(ContactModel.fromDomain(contact).toJson());
    return contact;
  }

  Future<void> deleteContact(String userId, String contactId) async {
    log('deleteContact – id=$contactId', name: 'ContactService');
    await _ref(userId).doc(contactId).delete();
  }
}
