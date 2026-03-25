import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../providers/check_in_provider.dart';
import '../../../providers/config_provider.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../../domain/entities/check_in_config.dart';

class CheckInButton extends ConsumerStatefulWidget {
  const CheckInButton({super.key});

  @override
  ConsumerState<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends ConsumerState<CheckInButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild every 30 s so time-based transitions (ok → windowOpen/grace/overdue)
    // are reflected without requiring a provider state change.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final configState = ref.watch(configNotifierProvider);
    final isLoading = checkInState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    final lastCheckIn = checkInState.valueOrNull;
    final config = configState.valueOrNull;

    final effectiveConfig = config ?? CheckInConfig.defaults();
    final bool isAllowed =
        TimeUtils.isCheckInAllowed(lastCheckIn?.timestamp, effectiveConfig);

    String? availableFromText;
    if (!isAllowed && lastCheckIn != null) {
      final windowStart =
          TimeUtils.checkInWindowStart(lastCheckIn.timestamp, effectiveConfig);
      availableFromText =
          l10n.checkInAvailableFrom(DateFormat('HH:mm').format(windowStart));
    }

    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        onPressed: (isLoading || !isAllowed)
            ? null
            : () => ref.read(checkInNotifierProvider.notifier).performCheckIn(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isAllowed
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: isAllowed
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurfaceVariant,
          elevation: isAllowed ? 8 : 2,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isAllowed ? Icons.check : Icons.lock_clock, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    isAllowed
                        ? l10n.checkInButton
                        : (availableFromText ?? l10n.checkInButton),
                    style: TextStyle(
                      fontSize: isAllowed ? 20 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
