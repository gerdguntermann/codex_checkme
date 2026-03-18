import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/check_in_record.dart';
import 'auth_provider.dart';
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
    } catch (e, stack) {
      log('performCheckIn – error: $e', name: 'CheckInNotifier');
      state = AsyncError(e, stack);
    }
  }
}

final checkInNotifierProvider =
    AsyncNotifierProvider<CheckInNotifier, CheckInRecord?>(CheckInNotifier.new);
