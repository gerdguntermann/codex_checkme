import 'package:dartz/dartz.dart';
import '../entities/check_in_config.dart';
import '../repositories/config_repository.dart';
import '../../core/error/failures.dart';

class GetConfig {
  final ConfigRepository repository;
  const GetConfig(this.repository);

  Future<Either<Failure, CheckInConfig>> call(String userId) {
    return repository.getConfig(userId);
  }
}
