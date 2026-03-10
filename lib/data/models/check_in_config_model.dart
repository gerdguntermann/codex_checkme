import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/check_in_config.dart';

part 'check_in_config_model.g.dart';

@JsonSerializable()
class CheckInConfigModel {
  final int intervalMinutes;
  final int timeWindowStartHour;
  final int timeWindowStartMinute;
  final int timeWindowEndHour;
  final int timeWindowEndMinute;
  final int gracePeriodMinutes;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfigModel({
    required this.intervalMinutes,
    required this.timeWindowStartHour,
    required this.timeWindowStartMinute,
    required this.timeWindowEndHour,
    required this.timeWindowEndMinute,
    required this.gracePeriodMinutes,
    required this.maxNotifications,
    required this.isActive,
  });

  factory CheckInConfigModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInConfigModelToJson(this);

  factory CheckInConfigModel.fromDomain(CheckInConfig config) =>
      CheckInConfigModel(
        intervalMinutes: config.intervalMinutes,
        timeWindowStartHour: config.timeWindowStartHour,
        timeWindowStartMinute: config.timeWindowStartMinute,
        timeWindowEndHour: config.timeWindowEndHour,
        timeWindowEndMinute: config.timeWindowEndMinute,
        gracePeriodMinutes: config.gracePeriodMinutes,
        maxNotifications: config.maxNotifications,
        isActive: config.isActive,
      );

  CheckInConfig toDomain() => CheckInConfig(
        intervalMinutes: intervalMinutes,
        timeWindowStartHour: timeWindowStartHour,
        timeWindowStartMinute: timeWindowStartMinute,
        timeWindowEndHour: timeWindowEndHour,
        timeWindowEndMinute: timeWindowEndMinute,
        gracePeriodMinutes: gracePeriodMinutes,
        maxNotifications: maxNotifications,
        isActive: isActive,
      );
}
