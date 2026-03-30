// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Daily OK';

  @override
  String get tooltipContacts => 'Contacts';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String authError(Object error) {
    return 'Auth error: $error';
  }

  @override
  String get tapToConfirm => 'Tap to confirm you\'re OK';

  @override
  String get checkInButton => 'I\'m OK';

  @override
  String genericError(Object error) {
    return 'Error: $error';
  }

  @override
  String get noCheckInsYet => 'No check-ins yet';

  @override
  String get pressButtonToStart => 'Press the button to start';

  @override
  String get statusOverdue => 'OVERDUE';

  @override
  String get statusGrace => 'GRACE PERIOD';

  @override
  String get statusOk => 'OK';

  @override
  String get statusWindowOpen => 'WINDOW OPEN';

  @override
  String get checkInRequired => 'Check-in required!';

  @override
  String get overdueSinceLabel => 'Overdue since';

  @override
  String get graceMessage => 'Check-in soon required';

  @override
  String get allGood => 'All good';

  @override
  String get windowOpenMessage => 'Check-in window open';

  @override
  String get checkInWindowStartLabel => 'Check-in from';

  @override
  String checkInAvailableFrom(String time) {
    return 'Available from $time';
  }

  @override
  String get lastCheckIn => 'Last check-in';

  @override
  String get nextDeadline => 'Next deadline';

  @override
  String get tomorrow => 'tomorrow';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get timingModeLabel => 'Mode';

  @override
  String get timingModeFixedTime => 'Fixed Time';

  @override
  String get timingModeInterval => 'Interval';

  @override
  String get dailyCheckInTime => 'Daily Check-in Time';

  @override
  String get timeUnitSuffix => '';

  @override
  String get checkInIntervalLabel => 'Check-in Interval';

  @override
  String get hourUnit => 'h';

  @override
  String get gracePeriodLabel => 'Grace Period after deadline';

  @override
  String get preDeadlineLabel => 'Check-in window before deadline';

  @override
  String get minuteUnit => 'min';

  @override
  String get maxNotificationsLabel => 'Max. notifications / day';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get monitoringActive => 'Monitoring active';

  @override
  String get monitoringSubtitle => 'Toggle all notifications on/off';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get noContactsYet => 'No contacts yet';

  @override
  String get tapToAddContact => 'Tap + to add a contact';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldEmail => 'Email';

  @override
  String get fieldPhone => 'Phone (optional)';

  @override
  String get phoneHint => '+49123456789';

  @override
  String get nameRequired => 'Name required';

  @override
  String get emailRequired => 'Email required';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String deleteContactConfirm(Object name) {
    return 'Delete $name?';
  }

  @override
  String get delete => 'Delete';
}
