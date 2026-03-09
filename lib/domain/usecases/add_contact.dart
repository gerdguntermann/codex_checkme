import 'package:dartz/dartz.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';
import '../../core/error/failures.dart';

class AddContact {
  final ContactRepository repository;
  const AddContact(this.repository);

  Future<Either<Failure, Contact>> call(String userId, Contact contact) {
    return repository.addContact(userId, contact);
  }
}
