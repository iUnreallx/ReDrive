// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get connection => 'Connection';

  @override
  String get garage => 'Garage';

  @override
  String get dtc => 'DTC';

  @override
  String get speed => 'Speed';

  @override
  String get rpm => 'RPM';

  @override
  String get preparing => 'Preparing connection...';

  @override
  String get connectingEcu => 'Connecting to ECU...';

  @override
  String get initializing => 'Initializing ELM327...';

  @override
  String get connected => 'Connected';

  @override
  String get recovering => 'Recovering connection...';

  @override
  String get connectionError => 'Connection error';

  @override
  String get cancel => 'Cancel';

  @override
  String get settings => 'Settings';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get usb => 'USB';

  @override
  String get usbDeveloping => 'USB connection is under development';

  @override
  String get bluetoothConnection => 'Bluetooth Connection';

  @override
  String get bluetoothDescription =>
      'Connect your OBD2 adapter to see\nreal-time vehicle data.';

  @override
  String get wifiConnection => 'Wi-Fi Connection';

  @override
  String get wifiDescription =>
      'Join the adapter\'s Wi-Fi network,\nthen enter its address.';

  @override
  String get ipAddress => 'IP address';

  @override
  String get port => 'Port';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get notConnected => 'Not connected';

  @override
  String connectingTo(String target) {
    return 'Connecting to $target...';
  }

  @override
  String connectedTo(String target) {
    return 'Connected to $target';
  }

  @override
  String get invalidAddress => 'Enter a valid IP address and port';

  @override
  String adapterNotResponding(String target) {
    return 'No response from $target';
  }

  @override
  String get startScanning => 'Start Scanning';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanningComplete => 'Scanning complete';

  @override
  String get searchingAdapter => 'Searching for your adapter...';

  @override
  String devicesFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Found $n devices',
      one: 'Found $n device',
    );
    return '$_temp0';
  }

  @override
  String get permissionTitle => 'Bluetooth access required';

  @override
  String get permissionDescription =>
      'Bluetooth permission was permanently denied. Please enable it from app settings.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get garageTitle => 'My Garage';

  @override
  String get garageDescription => 'Your vehicles will appear here';

  @override
  String get noVehicles => 'No vehicles';

  @override
  String get addFirstVehicle => 'Add your first\nvehicle';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get vehicleConnected => 'Vehicle is connected';

  @override
  String get connect => 'Connect';

  @override
  String get disconnectDemo => 'Disconnect';

  @override
  String get viewDemo => 'View demo';

  @override
  String get connectAdapterFirst =>
      'Connect a Bluetooth, Wi-Fi, or USB adapter first';

  @override
  String get ecuFailed => 'Unable to connect to ECU';

  @override
  String get disconnectEcuFirst => 'Disconnect from the ECU first';

  @override
  String get bannerRestoring => 'Restoring connection';

  @override
  String get bannerReconnecting => 'Reconnecting';

  @override
  String get reconnectWait => 'Reconnecting, please wait';

  @override
  String get connectionLost => 'Connection lost. Please connect again';
}
