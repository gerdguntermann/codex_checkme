import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/check_in_record.dart';

part 'check_in_record_model.g.dart';

@JsonSerializable()
class CheckInRecordModel {
  final String id;
  final String userId;
  @JsonKey(fromJson: _dateTimeFromTimestamp)
  final DateTime timestamp;

  const CheckInRecordModel({
    required this.id,
    required this.userId,
    required this.timestamp,
  });

  factory CheckInRecordModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInRecordModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInRecordModelToJson(this);

  CheckInRecord toDomain() =>
      CheckInRecord(id: id, userId: userId, timestamp: timestamp);

  factory CheckInRecordModel.fromDomain(CheckInRecord record) =>
      CheckInRecordModel(
        id: record.id,
        userId: record.userId,
        timestamp: record.timestamp,
      );

  static DateTime _dateTimeFromTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value); // migration: alte int-Werte
    throw ArgumentError('Cannot convert $value (${value.runtimeType}) to DateTime');
  }
}
