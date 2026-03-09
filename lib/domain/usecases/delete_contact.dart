import 'package:dartz/dartz.dart';
import '../repositories/contact_repository.dart';
import '../../core/error/failures.dart';

class DeleteContact {
  final ContactRepository repository;
  const DeleteContact(this.repository);

  Future<Either<Failure, void>> call(String userId, String contactId) {
    return repository.deleteContact(userId, contactId);
  }
}
