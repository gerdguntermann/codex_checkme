import 'package:checkme/core/utils/app_logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../background/background_service.dart';
import '../../domain/entities/check_in_config.dart';
import '../../domain/entities/check_in_record.dart';
import 'auth_provider.dart';
import 'config_provider.dart';
import 'service_providers.dart';

class CheckInNotifier extends AsyncNotifier<CheckInRecord?> {
  @override
  Future<CheckInRecord?> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      log('build – no user', name: 'CheckInNotifier');
      return null;
    }
    log('build – loading last check-in', name: 'CheckInNotifier');
    final record = await ref.read(checkInServiceProvider).getLastCheckIn(userId);
    log('build – ${record?.timestamp ?? 'none'}', name: 'CheckInNotifier');
    return record;
  }

  Future<void> performCheckIn() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    log('performCheckIn – starting', name: 'CheckInNotifier');
    try {
      final record = await ref.read(checkInServiceProvider).performCheckIn(userId);
      log('performCheckIn – success: ${record.timestamp}', name: 'CheckInNotifier');
      state = AsyncData(record);
      // Re-align Workmanager to the next window start after check-in.
      try {
        final config =
            ref.read(configNotifierProvider).valueOrNull ?? CheckInConfig.defaults();
        await BackgroundService.registerNextWindow(config);
      } catch (e) {
        log('performCheckIn – background re-register skipped: $e',
            name: 'CheckInNotifier');
      }
    } catch (e, stack) {
      log('performCheckIn – error: $e', name: 'CheckInNotifier');
      state = AsyncError(e, stack);
    }
  }
}

final checkInNotifierProvider =
    AsyncNotifierProvider<CheckInNotifier, CheckInRecord?>(CheckInNotifier.new);
