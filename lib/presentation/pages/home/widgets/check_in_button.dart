import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/check_in_provider.dart';

class CheckInButton extends ConsumerWidget {
  const CheckInButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInState = ref.watch(checkInNotifierProvider);
    final isLoading = checkInState.isLoading;

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
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, size: 64),
                  SizedBox(height: 8),
                  Text(
                    'I\'m OK',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}
