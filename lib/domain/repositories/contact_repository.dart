import 'package:dartz/dartz.dart';
import '../entities/contact.dart';
import '../../core/error/failures.dart';

abstract class ContactRepository {
  Future<Either<Failure, List<Contact>>> getContacts(String userId);
  Future<Either<Failure, Contact>> addContact(String userId, Contact contact);
  Future<Either<Failure, Contact>> updateContact(String userId, Contact contact);
  Future<Either<Failure, void>> deleteContact(String userId, String contactId);
}
