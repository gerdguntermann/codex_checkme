import 'package:dartz/dartz.dart';
import '../entities/check_in_config.dart';
import '../repositories/config_repository.dart';
import '../../core/error/failures.dart';

class SaveConfig {
  final ConfigRepository repository;
  const SaveConfig(this.repository);

  Future<Either<Failure, void>> call(String userId, CheckInConfig config) {
    return repository.saveConfig(userId, config);
  }
}
