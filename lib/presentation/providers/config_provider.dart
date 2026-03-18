import 'dart:developer';

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
    state = AsyncData(config);
    log('saveConfig – saving', name: 'ConfigNotifier');
    try {
      await ref.read(configServiceProvider).saveConfig(userId, config);
    } catch (e, stack) {
      log('saveConfig – error: $e', name: 'ConfigNotifier');
      state = AsyncError(e, stack);
    }
  }
}

final configNotifierProvider =
    AsyncNotifierProvider<ConfigNotifier, CheckInConfig>(ConfigNotifier.new);
