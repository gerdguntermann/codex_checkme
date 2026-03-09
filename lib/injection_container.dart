import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'data/datasources/local/config_local_datasource.dart';
import 'data/datasources/remote/check_in_remote_datasource.dart';
import 'data/datasources/remote/config_remote_datasource.dart';
import 'data/datasources/remote/contact_remote_datasource.dart';
import 'data/repositories/check_in_repository_impl.dart';
import 'data/repositories/config_repository_impl.dart';
import 'data/repositories/contact_repository_impl.dart';
import 'domain/repositories/check_in_repository.dart';
import 'domain/repositories/config_repository.dart';
import 'domain/repositories/contact_repository.dart';
import 'domain/usecases/add_contact.dart';
import 'domain/usecases/delete_contact.dart';
import 'domain/usecases/get_check_in_status.dart';
import 'domain/usecases/get_config.dart';
import 'domain/usecases/get_contacts.dart';
import 'domain/usecases/perform_check_in.dart';
import 'domain/usecases/save_config.dart';
import 'domain/usecases/update_contact.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => const Uuid());

  // Datasources
  sl.registerLazySingleton<ConfigLocalDatasource>(
    () => ConfigLocalDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<CheckInRemoteDatasource>(
    () => CheckInRemoteDatasourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ConfigRemoteDatasource>(
    () => ConfigRemoteDatasourceImpl(sl()),
  );
  sl.registerLazySingleton<ContactRemoteDatasource>(
    () => ContactRemoteDatasourceImpl(sl(), sl()),
  );

  // Repositories
  sl.registerLazySingleton<CheckInRepository>(
    () => CheckInRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => PerformCheckIn(sl()));
  sl.registerLazySingleton(() => GetCheckInStatus(sl()));
  sl.registerLazySingleton(() => GetConfig(sl()));
  sl.registerLazySingleton(() => SaveConfig(sl()));
  sl.registerLazySingleton(() => GetContacts(sl()));
  sl.registerLazySingleton(() => AddContact(sl()));
  sl.registerLazySingleton(() => UpdateContact(sl()));
  sl.registerLazySingleton(() => DeleteContact(sl()));
}
