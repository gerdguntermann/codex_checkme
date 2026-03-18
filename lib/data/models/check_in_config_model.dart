import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/check_in_config.dart';

part 'check_in_config_model.g.dart';

@JsonSerializable()
class CheckInConfigModel {
  @JsonKey(defaultValue: 'fixedTime')
  final String timingMode;
  @JsonKey(defaultValue: 9)
  final int checkInHour;
  @JsonKey(defaultValue: 0)
  final int checkInMinute;
  @JsonKey(defaultValue: 240)
  final int intervalMinutes;
  final int gracePeriodMinutes;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfigModel({
    required this.timingMode,
    required this.checkInHour,
    required this.checkInMinute,
    required this.intervalMinutes,
    required this.gracePeriodMinutes,
    required this.maxNotifications,
    required this.isActive,
  });

  factory CheckInConfigModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInConfigModelToJson(this);

  factory CheckInConfigModel.fromDomain(CheckInConfig config) =>
      CheckInConfigModel(
        timingMode: config.timingMode.name,
        checkInHour: config.checkInHour,
        checkInMinute: config.checkInMinute,
        intervalMinutes: config.intervalMinutes,
        gracePeriodMinutes: config.gracePeriodMinutes,
        maxNotifications: config.maxNotifications,
        isActive: config.isActive,
      );

  CheckInConfig toDomain() => CheckInConfig(
        timingMode: TimingMode.values.firstWhere(
          (e) => e.name == timingMode,
          orElse: () => TimingMode.fixedTime,
        ),
        checkInHour: checkInHour,
        checkInMinute: checkInMinute,
        intervalMinutes: intervalMinutes,
        gracePeriodMinutes: gracePeriodMinutes,
        maxNotifications: maxNotifications,
        isActive: isActive,
      );
}
