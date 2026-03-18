import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/l10n/app_localizations.dart';
import '../../../providers/check_in_provider.dart';

class CheckInButton extends ConsumerWidget {
  const CheckInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final isLoading = checkInState.isLoading;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: 200,
      height: 200,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () => ref.read(checkInNotifierProvider.notifier).performCheckIn(),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 8,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    l10n.checkInButton,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
