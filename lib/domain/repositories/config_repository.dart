import 'package:dartz/dartz.dart';
import '../entities/check_in_config.dart';
import '../../core/error/failures.dart';

abstract class ConfigRepository {
  Future<Either<Failure, CheckInConfig>> getConfig(String userId);
  Future<Either<Failure, void>> saveConfig(String userId, CheckInConfig config);
}
