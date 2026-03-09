import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/check_in_config_model.dart';
import '../../../core/error/exceptions.dart';

abstract class ConfigLocalDatasource {
  Future<CheckInConfigModel> getConfig();
  Future<void> saveConfig(CheckInConfigModel config);
}

class ConfigLocalDatasourceImpl implements ConfigLocalDatasource {
  final SharedPreferences prefs;
  static const _key = 'check_in_config';

  ConfigLocalDatasourceImpl(this.prefs);

  @override
  Future<CheckInConfigModel> getConfig() async {
    final json = prefs.getString(_key);
    if (json == null) throw const CacheException('No config cached');
    return CheckInConfigModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  Future<void> saveConfig(CheckInConfigModel config) async {
    await prefs.setString(_key, jsonEncode(config.toJson()));
  }
}
