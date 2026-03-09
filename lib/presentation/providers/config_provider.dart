import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_in_config.dart';
import '../../domain/usecases/get_config.dart';
import '../../domain/usecases/save_config.dart';
import '../../injection_container.dart';
import 'auth_provider.dart';

class ConfigNotifier extends AsyncNotifier<CheckInConfig> {
  @override
  Future<CheckInConfig> build() async {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return CheckInConfig.defaults();
    final useCase = sl<GetConfig>();
    final result = await useCase(userId);
    return result.fold((_) => CheckInConfig.defaults(), (config) => config);
  }

  Future<void> saveConfig(CheckInConfig config) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    state = AsyncData(config);
    final useCase = sl<SaveConfig>();
    final result = await useCase(userId, config);
    result.fold(
      (failure) => state = AsyncError(failure.message, StackTrace.current),
      (_) {},
    );
  }
}

final configNotifierProvider =
    AsyncNotifierProvider<ConfigNotifier, CheckInConfig>(ConfigNotifier.new);
