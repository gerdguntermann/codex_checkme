import 'package:equatable/equatable.dart';

/// A single daily check-in window defined by start and end wall-clock times.
/// All values use 24-hour format.
class CheckInWindow extends Equatable {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const CheckInWindow({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  CheckInWindow copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) =>
      CheckInWindow(
        startHour: startHour ?? this.startHour,
        startMinute: startMinute ?? this.startMinute,
        endHour: endHour ?? this.endHour,
        endMinute: endMinute ?? this.endMinute,
      );

  @override
  List<Object?> get props => [startHour, startMinute, endHour, endMinute];
}

class CheckInConfig extends Equatable {
  /// One or two daily check-in windows, sorted by start time.
  final List<CheckInWindow> windows;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfig({
    required this.windows,
    required this.maxNotifications,
    required this.isActive,
  });

  factory CheckInConfig.defaults() => const CheckInConfig(
        windows: [
          CheckInWindow(
              startHour: 9, startMinute: 0, endHour: 10, endMinute: 0),
        ],
        maxNotifications: 3,
        isActive: true,
      );

  CheckInConfig copyWith({
    List<CheckInWindow>? windows,
    int? maxNotifications,
    bool? isActive,
  }) =>
      CheckInConfig(
        windows: windows ?? this.windows,
        maxNotifications: maxNotifications ?? this.maxNotifications,
        isActive: isActive ?? this.isActive,
      );

  @override
  List<Object?> get props => [windows, maxNotifications, isActive];
}
