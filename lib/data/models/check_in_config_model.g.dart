// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInConfigModel _$CheckInConfigModelFromJson(Map<String, dynamic> json) =>
    CheckInConfigModel(
      intervalHours: (json['intervalHours'] as num).toInt(),
      timeWindowStartHour: (json['timeWindowStartHour'] as num).toInt(),
      timeWindowStartMinute: (json['timeWindowStartMinute'] as num).toInt(),
      timeWindowEndHour: (json['timeWindowEndHour'] as num).toInt(),
      timeWindowEndMinute: (json['timeWindowEndMinute'] as num).toInt(),
      gracePeriodMinutes: (json['gracePeriodMinutes'] as num).toInt(),
      maxNotifications: (json['maxNotifications'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CheckInConfigModelToJson(CheckInConfigModel instance) =>
    <String, dynamic>{
      'intervalHours': instance.intervalHours,
      'timeWindowStartHour': instance.timeWindowStartHour,
      'timeWindowStartMinute': instance.timeWindowStartMinute,
      'timeWindowEndHour': instance.timeWindowEndHour,
      'timeWindowEndMinute': instance.timeWindowEndMinute,
      'gracePeriodMinutes': instance.gracePeriodMinutes,
      'maxNotifications': instance.maxNotifications,
      'isActive': instance.isActive,
    };
