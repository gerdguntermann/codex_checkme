import 'package:dartz/dartz.dart';
import '../../domain/entities/check_in_record.dart';
import '../../domain/repositories/check_in_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/check_in_remote_datasource.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInRemoteDatasource remoteDatasource;

  CheckInRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, CheckInRecord>> performCheckIn(String userId) async {
    try {
      final model = await remoteDatasource.performCheckIn(userId);
      return Right(model.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, CheckInRecord?>> getLastCheckIn(String userId) async {
    try {
      final model = await remoteDatasource.getLastCheckIn(userId);
      return Right(model?.toDomain());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<CheckInRecord>>> getCheckInHistory(String userId, {int limit = 20}) async {
    try {
      final models = await remoteDatasource.getCheckInHistory(userId, limit: limit);
      return Right(models.map((m) => m.toDomain()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
