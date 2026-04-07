// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'My Daily OK';

  @override
  String get tooltipContacts => 'Kontakte';

  @override
  String get tooltipSettings => 'Einstellungen';

  @override
  String authError(Object error) {
    return 'Auth-Fehler: $error';
  }

  @override
  String get tapToConfirm => 'Tippe um zu bestätigen, dass es dir gut geht';

  @override
  String get checkInButton => 'Ich bin OK';

  @override
  String genericError(Object error) {
    return 'Fehler: $error';
  }

  @override
  String get noCheckInsYet => 'Noch keine Check-ins';

  @override
  String get pressButtonToStart => 'Drücke den Button um zu starten';

  @override
  String get statusOverdue => 'ÜBERFÄLLIG';

  @override
  String get statusGrace => 'KARENZZEIT';

  @override
  String get statusOk => 'OK';

  @override
  String get statusWindowOpen => 'FENSTER OFFEN';

  @override
  String get checkInRequired => 'Check-in erforderlich!';

  @override
  String get overdueSinceLabel => 'Überfällig seit';

  @override
  String get graceMessage => 'Check-in bald erforderlich';

  @override
  String get allGood => 'Alles gut';

  @override
  String get windowOpenMessage => 'Check-in Fenster offen';

  @override
  String get checkInWindowStartLabel => 'Check-in ab';

  @override
  String checkInAvailableFrom(String time) {
    return 'Verfügbar ab $time';
  }

  @override
  String get lastCheckIn => 'Letzter Check-in';

  @override
  String get nextDeadline => 'Nächster Check-in';

  @override
  String get tomorrow => 'morgen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get timingModeLabel => 'Modus';

  @override
  String get timingModeFixedTime => 'Feste Uhrzeit';

  @override
  String get timingModeInterval => 'Intervall';

  @override
  String get dailyCheckInTime => 'Tägliche Check-in Zeit';

  @override
  String get timeUnitSuffix => ' Uhr';

  @override
  String get checkInIntervalLabel => 'Check-in Intervall';

  @override
  String get hourUnit => 'h';

  @override
  String get gracePeriodLabel => 'Karenzzeit nach Check-in';

  @override
  String get preDeadlineLabel => 'Check-in Fenster vor Check-in';

  @override
  String get minuteUnit => 'min';

  @override
  String get maxNotificationsLabel => 'Max. Benachrichtigungen / Tag';

  @override
  String get settingsSaved => 'Einstellungen gespeichert';

  @override
  String get monitoringActive => 'Monitoring aktiv';

  @override
  String get monitoringSubtitle => 'Alle Benachrichtigungen ein-/ausschalten';

  @override
  String get windowStartLabel => 'Fenster öffnet';

  @override
  String get windowEndLabel => 'Fenster schließt';

  @override
  String get addWindow => 'Zweites Zeitfenster hinzufügen';

  @override
  String get windowEndsAtLabel => 'Fenster endet';

  @override
  String get nextWindowLabel => 'Nächstes Fenster';

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String get noContactsYet => 'Noch keine Kontakte';

  @override
  String get tapToAddContact => 'Tippe + um einen Kontakt hinzuzufügen';

  @override
  String get addContact => 'Kontakt hinzufügen';

  @override
  String get editContact => 'Kontakt bearbeiten';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmail => 'E-Mail';

  @override
  String get fieldPhone => 'Telefon (optional)';

  @override
  String get phoneHint => '+49123456789';

  @override
  String get nameRequired => 'Name erforderlich';

  @override
  String get emailRequired => 'E-Mail erforderlich';

  @override
  String get invalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get deleteContact => 'Kontakt löschen';

  @override
  String deleteContactConfirm(Object name) {
    return '$name löschen?';
  }

  @override
  String get delete => 'Löschen';
}
