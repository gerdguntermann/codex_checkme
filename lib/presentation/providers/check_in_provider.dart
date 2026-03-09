import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_in_record.dart';
import '../../domain/usecases/perform_check_in.dart';
import '../../domain/usecases/get_check_in_status.dart';
import '../../injection_container.dart';
import 'auth_provider.dart';

final lastCheckInProvider = FutureProvider<CheckInRecord?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  final useCase = sl<GetCheckInStatus>();
  final result = await useCase(userId);
  return result.fold((_) => null, (record) => record);
});

class CheckInNotifier extends AsyncNotifier<CheckInRecord?> {
  @override
  Future<CheckInRecord?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return null;
    final useCase = sl<GetCheckInStatus>();
    final result = await useCase(userId);
    return result.fold((_) => null, (record) => record);
  }

  Future<void> performCheckIn() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final useCase = sl<PerformCheckIn>();
    final result = await useCase(userId);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (record) => state = AsyncData(record),
    );
  }
}

final checkInNotifierProvider =
    AsyncNotifierProvider<CheckInNotifier, CheckInRecord?>(CheckInNotifier.new);
