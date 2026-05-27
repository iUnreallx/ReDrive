import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redrive/models/bluetooth_enums.dart';

Future<BluetoothPermissionStatus> requestBluetoothPermissions() async {


  if (!Platform.isAndroid) return BluetoothPermissionStatus.granted;

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  final sdk = androidInfo.version.sdkInt;

  Map<Permission, PermissionStatus> statuses = {};

  if (sdk >= 31) {
    // Android 12+
    statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  } else if (sdk >= 29) {
    // Android 10–11
    statuses = await [Permission.location, Permission.bluetooth].request();
  } else {
    // Android 9 и ниже
    statuses = await [Permission.location].request();
  }

  final isPermanentlyDenied =
      statuses.values.any((s) => s.isPermanentlyDenied);
  if (isPermanentlyDenied) return BluetoothPermissionStatus.permanentlyDenied;

  final isGranted = statuses.values.every((s) => s.isGranted);
  return isGranted
      ? BluetoothPermissionStatus.granted
      : BluetoothPermissionStatus.denied;
}
