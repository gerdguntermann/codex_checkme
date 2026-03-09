import 'package:dartz/dartz.dart';
import '../entities/check_in_record.dart';
import '../../core/error/failures.dart';

abstract class CheckInRepository {
  Future<Either<Failure, CheckInRecord>> performCheckIn(String userId);
  Future<Either<Failure, CheckInRecord?>> getLastCheckIn(String userId);
  Future<Either<Failure, List<CheckInRecord>>> getCheckInHistory(String userId, {int limit = 20});
}
