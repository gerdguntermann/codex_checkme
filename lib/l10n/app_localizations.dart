import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'My Daily OK'**
  String get appTitle;

  /// No description provided for @tooltipContacts.
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get tooltipContacts;

  /// No description provided for @tooltipSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get tooltipSettings;

  /// No description provided for @authError.
  ///
  /// In de, this message translates to:
  /// **'Auth-Fehler: {error}'**
  String authError(Object error);

  /// No description provided for @tapToConfirm.
  ///
  /// In de, this message translates to:
  /// **'Tippe um zu bestätigen, dass es dir gut geht'**
  String get tapToConfirm;

  /// No description provided for @checkInButton.
  ///
  /// In de, this message translates to:
  /// **'Ich bin OK'**
  String get checkInButton;

  /// No description provided for @genericError.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String genericError(Object error);

  /// No description provided for @noCheckInsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Check-ins'**
  String get noCheckInsYet;

  /// No description provided for @pressButtonToStart.
  ///
  /// In de, this message translates to:
  /// **'Drücke den Button um zu starten'**
  String get pressButtonToStart;

  /// No description provided for @statusOverdue.
  ///
  /// In de, this message translates to:
  /// **'ÜBERFÄLLIG'**
  String get statusOverdue;

  /// No description provided for @statusGrace.
  ///
  /// In de, this message translates to:
  /// **'KARENZZEIT'**
  String get statusGrace;

  /// No description provided for @statusOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// No description provided for @statusWindowOpen.
  ///
  /// In de, this message translates to:
  /// **'FENSTER OFFEN'**
  String get statusWindowOpen;

  /// No description provided for @checkInRequired.
  ///
  /// In de, this message translates to:
  /// **'Check-in erforderlich!'**
  String get checkInRequired;

  /// No description provided for @overdueSinceLabel.
  ///
  /// In de, this message translates to:
  /// **'Überfällig seit'**
  String get overdueSinceLabel;

  /// No description provided for @graceMessage.
  ///
  /// In de, this message translates to:
  /// **'Check-in bald erforderlich'**
  String get graceMessage;

  /// No description provided for @allGood.
  ///
  /// In de, this message translates to:
  /// **'Alles gut'**
  String get allGood;

  /// No description provided for @windowOpenMessage.
  ///
  /// In de, this message translates to:
  /// **'Check-in Fenster offen'**
  String get windowOpenMessage;

  /// No description provided for @checkInWindowStartLabel.
  ///
  /// In de, this message translates to:
  /// **'Check-in ab'**
  String get checkInWindowStartLabel;

  /// No description provided for @checkInAvailableFrom.
  ///
  /// In de, this message translates to:
  /// **'Verfügbar ab {time}'**
  String checkInAvailableFrom(String time);

  /// No description provided for @lastCheckIn.
  ///
  /// In de, this message translates to:
  /// **'Letzter Check-in'**
  String get lastCheckIn;

  /// No description provided for @nextDeadline.
  ///
  /// In de, this message translates to:
  /// **'Nächster Check-in'**
  String get nextDeadline;

  /// No description provided for @tomorrow.
  ///
  /// In de, this message translates to:
  /// **'morgen'**
  String get tomorrow;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @timingModeLabel.
  ///
  /// In de, this message translates to:
  /// **'Modus'**
  String get timingModeLabel;

  /// No description provided for @timingModeFixedTime.
  ///
  /// In de, this message translates to:
  /// **'Feste Uhrzeit'**
  String get timingModeFixedTime;

  /// No description provided for @timingModeInterval.
  ///
  /// In de, this message translates to:
  /// **'Intervall'**
  String get timingModeInterval;

  /// No description provided for @dailyCheckInTime.
  ///
  /// In de, this message translates to:
  /// **'Tägliche Check-in Zeit'**
  String get dailyCheckInTime;

  /// No description provided for @timeUnitSuffix.
  ///
  /// In de, this message translates to:
  /// **' Uhr'**
  String get timeUnitSuffix;

  /// No description provided for @checkInIntervalLabel.
  ///
  /// In de, this message translates to:
  /// **'Check-in Intervall'**
  String get checkInIntervalLabel;

  /// No description provided for @hourUnit.
  ///
  /// In de, this message translates to:
  /// **'h'**
  String get hourUnit;

  /// No description provided for @gracePeriodLabel.
  ///
  /// In de, this message translates to:
  /// **'Karenzzeit nach Check-in'**
  String get gracePeriodLabel;

  /// No description provided for @preDeadlineLabel.
  ///
  /// In de, this message translates to:
  /// **'Check-in Fenster vor Check-in'**
  String get preDeadlineLabel;

  /// No description provided for @minuteUnit.
  ///
  /// In de, this message translates to:
  /// **'min'**
  String get minuteUnit;

  /// No description provided for @maxNotificationsLabel.
  ///
  /// In de, this message translates to:
  /// **'Max. Benachrichtigungen / Tag'**
  String get maxNotificationsLabel;

  /// No description provided for @settingsSaved.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen gespeichert'**
  String get settingsSaved;

  /// No description provided for @monitoringActive.
  ///
  /// In de, this message translates to:
  /// **'Monitoring aktiv'**
  String get monitoringActive;

  /// No description provided for @monitoringSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Benachrichtigungen ein-/ausschalten'**
  String get monitoringSubtitle;

  /// No description provided for @contactsTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get contactsTitle;

  /// No description provided for @noContactsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kontakte'**
  String get noContactsYet;

  /// No description provided for @tapToAddContact.
  ///
  /// In de, this message translates to:
  /// **'Tippe + um einen Kontakt hinzuzufügen'**
  String get tapToAddContact;

  /// No description provided for @addContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt hinzufügen'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt bearbeiten'**
  String get editContact;

  /// No description provided for @fieldName.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get fieldEmail;

  /// No description provided for @fieldPhone.
  ///
  /// In de, this message translates to:
  /// **'Telefon (optional)'**
  String get fieldPhone;

  /// No description provided for @phoneHint.
  ///
  /// In de, this message translates to:
  /// **'+49123456789'**
  String get phoneHint;

  /// No description provided for @nameRequired.
  ///
  /// In de, this message translates to:
  /// **'Name erforderlich'**
  String get nameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In de, this message translates to:
  /// **'E-Mail erforderlich'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail-Adresse'**
  String get invalidEmail;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @deleteContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt löschen'**
  String get deleteContact;

  /// No description provided for @deleteContactConfirm.
  ///
  /// In de, this message translates to:
  /// **'{name} löschen?'**
  String deleteContactConfirm(Object name);

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
