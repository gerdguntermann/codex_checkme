import 'package:dartz/dartz.dart';
import '../entities/contact.dart';
import '../repositories/contact_repository.dart';
import '../../core/error/failures.dart';

class GetContacts {
  final ContactRepository repository;
  const GetContacts(this.repository);

  Future<Either<Failure, List<Contact>>> call(String userId) {
    return repository.getContacts(userId);
  }
}
