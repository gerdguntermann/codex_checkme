import 'package:equatable/equatable.dart';

enum TimingMode { fixedTime, interval }

class CheckInConfig extends Equatable {
  final TimingMode timingMode;
  final int checkInHour;
  final int checkInMinute;
  final int intervalMinutes;
  final int gracePeriodMinutes;
  final int preDeadlineMinutes;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfig({
    required this.timingMode,
    required this.checkInHour,
    required this.checkInMinute,
    required this.intervalMinutes,
    required this.gracePeriodMinutes,
    required this.preDeadlineMinutes,
    required this.maxNotifications,
    required this.isActive,
  });

  factory CheckInConfig.defaults() => const CheckInConfig(
        timingMode: TimingMode.fixedTime,
        checkInHour: 9,
        checkInMinute: 0,
        intervalMinutes: 240,
        gracePeriodMinutes: 30,
        preDeadlineMinutes: 60,
        maxNotifications: 3,
        isActive: true,
      );

  CheckInConfig copyWith({
    TimingMode? timingMode,
    int? checkInHour,
    int? checkInMinute,
    int? intervalMinutes,
    int? gracePeriodMinutes,
    int? preDeadlineMinutes,
    int? maxNotifications,
    bool? isActive,
  }) {
    return CheckInConfig(
      timingMode: timingMode ?? this.timingMode,
      checkInHour: checkInHour ?? this.checkInHour,
      checkInMinute: checkInMinute ?? this.checkInMinute,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      gracePeriodMinutes: gracePeriodMinutes ?? this.gracePeriodMinutes,
      preDeadlineMinutes: preDeadlineMinutes ?? this.preDeadlineMinutes,
      maxNotifications: maxNotifications ?? this.maxNotifications,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        timingMode,
        checkInHour,
        checkInMinute,
        intervalMinutes,
        gracePeriodMinutes,
        preDeadlineMinutes,
        maxNotifications,
        isActive,
      ];
}
