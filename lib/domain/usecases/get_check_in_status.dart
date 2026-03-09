import 'package:dartz/dartz.dart';
import '../entities/check_in_record.dart';
import '../repositories/check_in_repository.dart';
import '../../core/error/failures.dart';

class GetCheckInStatus {
  final CheckInRepository repository;
  const GetCheckInStatus(this.repository);

  Future<Either<Failure, CheckInRecord?>> call(String userId) {
    return repository.getLastCheckIn(userId);
  }
}
