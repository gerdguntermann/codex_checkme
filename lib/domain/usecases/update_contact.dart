import 'package:dartz/dartz.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';
import '../../core/error/failures.dart';

class UpdateContact {
  final ContactRepository repository;
  const UpdateContact(this.repository);

  Future<Either<Failure, Contact>> call(String userId, Contact contact) {
    return repository.updateContact(userId, contact);
  }
}
