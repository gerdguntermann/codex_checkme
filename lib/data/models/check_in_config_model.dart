import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/check_in_config.dart';

part 'check_in_config_model.g.dart';

@JsonSerializable()
class CheckInWindowModel {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const CheckInWindowModel({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory CheckInWindowModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInWindowModelFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInWindowModelToJson(this);

  factory CheckInWindowModel.fromDomain(CheckInWindow w) => CheckInWindowModel(
        startHour: w.startHour,
        startMinute: w.startMinute,
        endHour: w.endHour,
        endMinute: w.endMinute,
      );

  CheckInWindow toDomain() => CheckInWindow(
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
      );
}

@JsonSerializable(explicitToJson: true)
class CheckInConfigModel {
  @JsonKey(defaultValue: [])
  final List<CheckInWindowModel> windows;
  final int maxNotifications;
  final bool isActive;

  const CheckInConfigModel({
    required this.windows,
    required this.maxNotifications,
    required this.isActive,
  });

  /// Migrates old Firestore documents (checkInHour/gracePeriodMinutes format)
  /// to the new windows-based format.
  factory CheckInConfigModel.fromJson(Map<String, dynamic> json) {
    final rawWindows = json['windows'];
    if (rawWindows == null || (rawWindows as List).isEmpty) {
      // Old format – derive a single window from deadline + grace period.
      final hour = json['checkInHour'] as int? ?? 9;
      final minute = json['checkInMinute'] as int? ?? 0;
      final grace = json['gracePeriodMinutes'] as int? ?? 60;
      final endTotal = hour * 60 + minute + grace;
      return CheckInConfigModel(
        windows: [
          CheckInWindowModel(
            startHour: hour,
            startMinute: minute,
            endHour: endTotal ~/ 60 % 24,
            endMinute: endTotal % 60,
          ),
        ],
        maxNotifications: json['maxNotifications'] as int? ?? 3,
        isActive: json['isActive'] as bool? ?? true,
      );
    }
    return _$CheckInConfigModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$CheckInConfigModelToJson(this);

  factory CheckInConfigModel.fromDomain(CheckInConfig config) =>
      CheckInConfigModel(
        windows: config.windows.map(CheckInWindowModel.fromDomain).toList(),
        maxNotifications: config.maxNotifications,
        isActive: config.isActive,
      );

  CheckInConfig toDomain() => CheckInConfig(
        windows: windows.isEmpty
            ? CheckInConfig.defaults().windows
            : windows.map((w) => w.toDomain()).toList(),
        maxNotifications: maxNotifications,
        isActive: isActive,
      );
}
