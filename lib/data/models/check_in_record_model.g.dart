// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckInRecordModel _$CheckInRecordModelFromJson(Map<String, dynamic> json) =>
    CheckInRecordModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      timestamp: CheckInRecordModel._dateTimeFromTimestamp(json['timestamp']),
    );

Map<String, dynamic> _$CheckInRecordModelToJson(CheckInRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'timestamp': CheckInRecordModel._dateTimeToTimestamp(instance.timestamp),
    };
