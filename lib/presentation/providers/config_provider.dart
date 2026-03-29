import 'package:checkme/core/utils/app_logger.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/check_in_config.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

class ConfigNotifier extends AsyncNotifier<CheckInConfig> {
  @override
  Future<CheckInConfig> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return CheckInConfig.defaults();
    log('build – loading config', name: 'ConfigNotifier');
    return ref.read(configServiceProvider).getConfig(userId);
  }

  Future<void> saveConfig(CheckInConfig config) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final previous = state.valueOrNull;
    final deadlineChanged = previous != null && _isDeadlineChanged(previous, config);

    state = AsyncData(config);
    log('saveConfig – saving (deadlineChanged=$deadlineChanged)', name: 'ConfigNotifier');
    try {
      await ref.read(configServiceProvider).saveConfig(userId, config);
      if (deadlineChanged) {
        log('saveConfig – deadline changed, performing implicit check-in', name: 'ConfigNotifier');
        await ref.read(checkInServiceProvider).performCheckIn(userId);
      }
    } catch (e, stack) {
      log('saveConfig – error: $e', name: 'ConfigNotifier');
      state = AsyncError(e, stack);
    }
  }

  bool _isDeadlineChanged(CheckInConfig previous, CheckInConfig next) =>
      previous.timingMode != next.timingMode ||
      previous.checkInHour != next.checkInHour ||
      previous.checkInMinute != next.checkInMinute ||
      previous.intervalMinutes != next.intervalMinutes;
}

final configNotifierProvider =
    AsyncNotifierProvider<ConfigNotifier, CheckInConfig>(ConfigNotifier.new);
