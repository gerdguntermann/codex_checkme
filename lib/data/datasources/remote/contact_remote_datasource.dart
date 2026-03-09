import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../models/contact_model.dart';
import '../../../core/constants/firestore_constants.dart';
import '../../../core/error/exceptions.dart';

abstract class ContactRemoteDatasource {
  Future<List<ContactModel>> getContacts(String userId);
  Future<ContactModel> addContact(String userId, ContactModel contact);
  Future<ContactModel> updateContact(String userId, ContactModel contact);
  Future<void> deleteContact(String userId, String contactId);
}

class ContactRemoteDatasourceImpl implements ContactRemoteDatasource {
  final FirebaseFirestore firestore;
  final Uuid uuid;

  ContactRemoteDatasourceImpl(this.firestore, this.uuid);

  CollectionReference<Map<String, dynamic>> _contactsRef(String userId) =>
      firestore
          .collection(FirestoreConstants.usersCollection)
          .doc(userId)
          .collection(FirestoreConstants.contactsCollection);

  @override
  Future<List<ContactModel>> getContacts(String userId) async {
    try {
      final snapshot = await _contactsRef(userId).get();
      return snapshot.docs
          .map((doc) => ContactModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get contacts: $e');
    }
  }

  @override
  Future<ContactModel> addContact(String userId, ContactModel contact) async {
    try {
      final withId = ContactModel(
        id: contact.id.isEmpty ? uuid.v4() : contact.id,
        name: contact.name,
        email: contact.email,
      );
      await _contactsRef(userId).doc(withId.id).set(withId.toJson());
      return withId;
    } catch (e) {
      throw ServerException('Failed to add contact: $e');
    }
  }

  @override
  Future<ContactModel> updateContact(String userId, ContactModel contact) async {
    try {
      await _contactsRef(userId).doc(contact.id).update(contact.toJson());
      return contact;
    } catch (e) {
      throw ServerException('Failed to update contact: $e');
    }
  }

  @override
  Future<void> deleteContact(String userId, String contactId) async {
    try {
      await _contactsRef(userId).doc(contactId).delete();
    } catch (e) {
      throw ServerException('Failed to delete contact: $e');
    }
  }
}
