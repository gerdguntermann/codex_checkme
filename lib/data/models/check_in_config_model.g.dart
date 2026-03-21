// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInConfigModel _$CheckInConfigModelFromJson(Map<String, dynamic> json) =>
    CheckInConfigModel(
      timingMode: json['timingMode'] as String? ?? 'fixedTime',
      checkInHour: (json['checkInHour'] as num?)?.toInt() ?? 9,
      checkInMinute: (json['checkInMinute'] as num?)?.toInt() ?? 0,
      intervalMinutes: (json['intervalMinutes'] as num?)?.toInt() ?? 240,
      gracePeriodMinutes: (json['gracePeriodMinutes'] as num).toInt(),
      preDeadlineMinutes: (json['preDeadlineMinutes'] as num?)?.toInt() ?? 60,
      maxNotifications: (json['maxNotifications'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CheckInConfigModelToJson(CheckInConfigModel instance) =>
    <String, dynamic>{
      'timingMode': instance.timingMode,
      'checkInHour': instance.checkInHour,
      'checkInMinute': instance.checkInMinute,
      'intervalMinutes': instance.intervalMinutes,
      'gracePeriodMinutes': instance.gracePeriodMinutes,
      'preDeadlineMinutes': instance.preDeadlineMinutes,
      'maxNotifications': instance.maxNotifications,
      'isActive': instance.isActive,
    };
