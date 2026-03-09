import 'package:dartz/dartz.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/contact_remote_datasource.dart';
import '../models/contact_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactRemoteDatasource remoteDatasource;

  ContactRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, List<Contact>>> getContacts(String userId) async {
    try {
      final models = await remoteDatasource.getContacts(userId);
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Contact>> addContact(String userId, Contact contact) async {
    try {
      final model = await remoteDatasource.addContact(
        userId,
        ContactModel.fromDomain(contact),
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Contact>> updateContact(String userId, Contact contact) async {
    try {
      final model = await remoteDatasource.updateContact(
        userId,
        ContactModel.fromDomain(contact),
      );
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact(String userId, String contactId) async {
    try {
      await remoteDatasource.deleteContact(userId, contactId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
