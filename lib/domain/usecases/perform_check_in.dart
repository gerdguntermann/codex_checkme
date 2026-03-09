import 'package:dartz/dartz.dart';
import '../entities/check_in_record.dart';
import '../repositories/check_in_repository.dart';
import '../../core/error/failures.dart';

class PerformCheckIn {
  final CheckInRepository repository;
  const PerformCheckIn(this.repository);

  Future<Either<Failure, CheckInRecord>> call(String userId) {
    return repository.performCheckIn(userId);
  }
}
