import 'package:dartz/dartz.dart';
import '../../domain/entities/check_in_config.dart';
import '../../domain/repositories/config_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/remote/config_remote_datasource.dart';
import '../datasources/local/config_local_datasource.dart';
import '../models/check_in_config_model.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigRemoteDatasource remoteDatasource;
  final ConfigLocalDatasource localDatasource;

  ConfigRepositoryImpl(this.remoteDatasource, this.localDatasource);

  @override
  Future<Either<Failure, CheckInConfig>> getConfig(String userId) async {
    try {
      // Try remote first
      final model = await remoteDatasource.getConfig(userId);
      // Cache locally on success
      await localDatasource.saveConfig(model);
      return Right(model.toDomain());
    } on ServerException {
      // Fall back to local cache
      try {
        final cached = await localDatasource.getConfig();
        return Right(cached.toDomain());
      } on CacheException {
        // Return defaults if nothing cached
        return const Right(CheckInConfig(
          intervalHours: 12,
          timeWindowStartHour: 8,
          timeWindowStartMinute: 0,
          timeWindowEndHour: 22,
          timeWindowEndMinute: 0,
          gracePeriodMinutes: 30,
          maxNotifications: 3,
          isActive: true,
        ));
      }
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(String userId, CheckInConfig config) async {
    try {
      final model = CheckInConfigModel.fromDomain(config);
      await remoteDatasource.saveConfig(userId, model);
      await localDatasource.saveConfig(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
