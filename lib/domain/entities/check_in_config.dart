import 'package:equatable/equatable.dart';

class CheckInConfig extends Equatable {
  final int intervalMinutes;
  final int timeWindowStartHour;
  final int timeWindowStartMinute;
  final int timeWindowEndHour;
  final int timeWindowEndMinute;
  final int gracePeriodMinutes;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfig({
    required this.intervalMinutes,
    required this.timeWindowStartHour,
    required this.timeWindowStartMinute,
    required this.timeWindowEndHour,
    required this.timeWindowEndMinute,
    required this.gracePeriodMinutes,
    required this.maxNotifications,
    required this.isActive,
  });

  factory CheckInConfig.defaults() => const CheckInConfig(
        intervalMinutes: 720,
        timeWindowStartHour: 8,
        timeWindowStartMinute: 0,
        timeWindowEndHour: 22,
        timeWindowEndMinute: 0,
        gracePeriodMinutes: 30,
        maxNotifications: 3,
        isActive: true,
      );

  CheckInConfig copyWith({
    int? intervalMinutes,
    int? timeWindowStartHour,
    int? timeWindowStartMinute,
    int? timeWindowEndHour,
    int? timeWindowEndMinute,
    int? gracePeriodMinutes,
    int? maxNotifications,
    bool? isActive,
  }) {
    return CheckInConfig(
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      timeWindowStartHour: timeWindowStartHour ?? this.timeWindowStartHour,
      timeWindowStartMinute: timeWindowStartMinute ?? this.timeWindowStartMinute,
      timeWindowEndHour: timeWindowEndHour ?? this.timeWindowEndHour,
      timeWindowEndMinute: timeWindowEndMinute ?? this.timeWindowEndMinute,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      maxNotifications: maxNotifications ?? this.maxNotifications,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        intervalMinutes,
        timeWindowStartHour,
        timeWindowStartMinute,
        timeWindowEndHour,
        timeWindowEndMinute,
        gracePeriodMinutes,
        maxNotifications,
        isActive,
      ];
}
