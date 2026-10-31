import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Bottom bar tab: home screen
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Bottom bar tab: live data dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Bottom bar tab: adapter connection
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// Bottom bar tab: saved vehicles
  ///
  /// In en, this message translates to:
  /// **'Garage'**
  String get garage;

  /// Bottom bar tab: d iagnostic trouble codes
  ///
  /// In en, this message translates to:
  /// **'DTC'**
  String get dtc;

  /// Gauge label for vehicle speed
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// Gauge label for engine revolutions per minute
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpm;

  /// Connection status: before the connection starts
  ///
  /// In en, this message translates to:
  /// **'Preparing connection...'**
  String get preparing;

  /// Connection status: talking to the car ECU
  ///
  /// In en, this message translates to:
  /// **'Connecting to ECU...'**
  String get connectingEcu;

  /// Connection status: setting up the adapter
  ///
  /// In en, this message translates to:
  /// **'Initializing ELM327...'**
  String get initializing;

  /// Connection status: connected
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Connection status: automatic recovery in progress
  ///
  /// In en, this message translates to:
  /// **'Recovering connection...'**
  String get recovering;

  /// Connection status: failed
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Connection type tab
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// Connection type tab
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get wifi;

  /// Connection type tab
  ///
  /// In en, this message translates to:
  /// **'USB'**
  String get usb;

  /// Placeholder text on the USB tab
  ///
  /// In en, this message translates to:
  /// **'USB connection is under development'**
  String get usbDeveloping;

  /// Title of the Bluetooth tab
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Connection'**
  String get bluetoothConnection;

  /// Hint under the Bluetooth tab title. The line break is intentional
  ///
  /// In en, this message translates to:
  /// **'Connect your OBD2 adapter to see\nreal-time vehicle data.'**
  String get bluetoothDescription;

  /// Title of the Wi-Fi tab
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Connection'**
  String get wifiConnection;

  /// Hint under the Wi-Fi tab title. The line break is intentional
  ///
  /// In en, this message translates to:
  /// **'Join the adapter\'s Wi-Fi network,\nthen enter its address.'**
  String get wifiDescription;

  /// Wi-Fi tab: address field label
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get ipAddress;

  /// Wi-Fi tab: port field label
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// Button: disconnect from the adapter
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Status: no adapter connected
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// Status while connecting to an adapter
  ///
  /// In en, this message translates to:
  /// **'Connecting to {target}...'**
  String connectingTo(String target);

  /// Status after connecting to an adapter
  ///
  /// In en, this message translates to:
  /// **'Connected to {target}'**
  String connectedTo(String target);

  /// Validation error on the Wi-Fi tab
  ///
  /// In en, this message translates to:
  /// **'Enter a valid IP address and port'**
  String get invalidAddress;

  /// Error when the adapter does not answer
  ///
  /// In en, this message translates to:
  /// **'No response from {target}'**
  String adapterNotResponding(String target);

  /// Button: start searching for Bluetooth devices
  ///
  /// In en, this message translates to:
  /// **'Start Scanning'**
  String get startScanning;

  /// Status while searching for Bluetooth devices
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// Status after the search finished
  ///
  /// In en, this message translates to:
  /// **'Scanning complete'**
  String get scanningComplete;

  /// Hint while searching for the adapter
  ///
  /// In en, this message translates to:
  /// **'Searching for your adapter...'**
  String get searchingAdapter;

  /// Number of Bluetooth devices found
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{Found {n} device} other{Found {n} devices}}'**
  String devicesFound(int n);

  /// Title when the Bluetooth permission is missing
  ///
  /// In en, this message translates to:
  /// **'Bluetooth access required'**
  String get permissionTitle;

  /// Explanation when the Bluetooth permission is permanently denied
  ///
  /// In en, this message translates to:
  /// **'Bluetooth permission was permanently denied. Please enable it from app settings.'**
  String get permissionDescription;

  /// Button: open system app settings
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Title of the garage screen
  ///
  /// In en, this message translates to:
  /// **'My Garage'**
  String get garageTitle;

  /// Hint on the garage screen
  ///
  /// In en, this message translates to:
  /// **'Your vehicles will appear here'**
  String get garageDescription;

  /// Empty state title on the garage screen
  ///
  /// In en, this message translates to:
  /// **'No vehicles'**
  String get noVehicles;

  /// Empty state text on the garage screen. The line break is intentional
  ///
  /// In en, this message translates to:
  /// **'Add your first\nvehicle'**
  String get addFirstVehicle;

  /// Button: add a vehicle
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// Status on the home screen
  ///
  /// In en, this message translates to:
  /// **'Vehicle is connected'**
  String get vehicleConnected;

  /// Button: connect to the vehicle
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Button: stop the demo mode
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectDemo;

  /// Button: start the demo mode
  ///
  /// In en, this message translates to:
  /// **'View demo'**
  String get viewDemo;

  /// Hint when no adapter is connected
  ///
  /// In en, this message translates to:
  /// **'Connect a Bluetooth, Wi-Fi, or USB adapter first'**
  String get connectAdapterFirst;

  /// Error: the car ECU did not answer
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to ECU'**
  String get ecuFailed;

  /// Hint: the ECU connection must be closed before the demo
  ///
  /// In en, this message translates to:
  /// **'Disconnect from the ECU first'**
  String get disconnectEcuFirst;

  /// Banner while the OBD session is being restored
  ///
  /// In en, this message translates to:
  /// **'Restoring connection'**
  String get bannerRestoring;

  /// Banner while the Bluetooth link is being reopened
  ///
  /// In en, this message translates to:
  /// **'Reconnecting'**
  String get bannerReconnecting;

  /// Message while a reconnect is in progress
  ///
  /// In en, this message translates to:
  /// **'Reconnecting, please wait'**
  String get reconnectWait;

  /// Message after all recovery attempts failed
  ///
  /// In en, this message translates to:
  /// **'Connection lost. Please connect again'**
  String get connectionLost;
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
      <String>['en', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
