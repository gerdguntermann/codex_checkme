// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInWindowModel _$CheckInWindowModelFromJson(Map<String, dynamic> json) =>
    CheckInWindowModel(
      startHour: (json['startHour'] as num).toInt(),
      startMinute: (json['startMinute'] as num).toInt(),
      endHour: (json['endHour'] as num).toInt(),
      endMinute: (json['endMinute'] as num).toInt(),
    );

Map<String, dynamic> _$CheckInWindowModelToJson(CheckInWindowModel instance) =>
    <String, dynamic>{
      'startHour': instance.startHour,
      'startMinute': instance.startMinute,
      'endHour': instance.endHour,
      'endMinute': instance.endMinute,
    };

CheckInConfigModel _$CheckInConfigModelFromJson(Map<String, dynamic> json) =>
    CheckInConfigModel(
      windows:
          (json['windows'] as List<dynamic>?)
              ?.map(
                (e) => CheckInWindowModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      maxNotifications: (json['maxNotifications'] as num).toInt(),
      isActive: json['isActive'] as bool,
    );

Map<String, dynamic> _$CheckInConfigModelToJson(CheckInConfigModel instance) =>
    <String, dynamic>{
      'windows': instance.windows.map((e) => e.toJson()).toList(),
      'maxNotifications': instance.maxNotifications,
      'isActive': instance.isActive,
    };
