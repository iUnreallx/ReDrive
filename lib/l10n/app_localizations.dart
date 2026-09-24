import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  bool get isChinese => locale.languageCode.toLowerCase() == 'zh';
  String get home => isChinese ? '主页' : 'Home';
  String get dashboard => isChinese ? '仪表盘' : 'Dashboard';
  String get connection => isChinese ? '连接' : 'Connection';
  String get garage => isChinese ? '车库' : 'Garage';
  String get dtc => isChinese ? '故障码' : 'DTC';
  String get speed => isChinese ? '车速' : 'Speed';
  String get rpm => isChinese ? '转速' : 'RPM';
  String get preparing => isChinese ? '准备连接...' : 'Preparing connection...';
  String get connectingEcu => isChinese ? '正在连接车辆 ECU...' : 'Connecting to ECU...';
  String get initializing => isChinese ? '正在初始化 ELM327...' : 'Initializing ELM327...';
  String get connected => isChinese ? '已连接' : 'Connected';
  String get recovering => isChinese ? '正在恢复连接...' : 'Recovering connection...';
  String get connectionError => isChinese ? '连接错误' : 'Connection error';
  String get cancel => isChinese ? '取消' : 'Cancel';
  String get settings => isChinese ? '设置' : 'Settings';
  String get bluetooth => isChinese ? '蓝牙' : 'Bluetooth';
  String get wifi => isChinese ? '无线网络' : 'Wi-Fi';
  String get usb => 'USB';
  String get wifiDeveloping => isChinese ? 'Wi‑Fi 连接功能正在开发中' : 'Wi-Fi connection is under development';
  String get usbDeveloping => isChinese ? 'USB 连接功能正在开发中' : 'USB connection is under development';
  String get bluetoothConnection => isChinese ? '蓝牙连接' : 'Bluetooth Connection';
  String get bluetoothDescription => isChinese ? '连接 OBD2 适配器后，\n即可查看车辆实时数据。' : 'Connect your OBD2 adapter to see\nreal-time vehicle data.';
  String get startScanning => isChinese ? '开始扫描' : 'Start Scanning';
  String get scanning => isChinese ? '扫描中...' : 'Scanning...';
  String get scanningComplete => isChinese ? '扫描完成' : 'Scanning complete';
  String get searchingAdapter => isChinese ? '正在搜索适配器...' : 'Searching for your adapter...';
  String devicesFound(int n) => isChinese ? '发现 $n 个设备' : 'Found $n devices';
  String get permissionTitle => isChinese ? '蓝牙权限不足' : 'Bluetooth access required';
  String get permissionDescription => isChinese ? '蓝牙权限已被永久拒绝，请前往系统设置开启。' : 'Bluetooth permission was permanently denied. Please enable it from app settings.';
  String get openSettings => isChinese ? '打开设置' : 'Open settings';
  String get garageTitle => isChinese ? '我的车库' : 'My Garage';
  String get garageDescription => isChinese ? '这里将显示你的车辆' : 'Your vehicles will appear here';
  String get noVehicles => isChinese ? '暂无车辆' : 'No vehicles';
  String get addFirstVehicle => isChinese ? '添加你的第一辆\n汽车' : 'Add your first\nvehicle';
  String get addVehicle => isChinese ? '添加车辆' : 'Add vehicle';
  String get vehicleConnected => isChinese ? '车辆已连接' : 'Vehicle is connected';
  String get connect => isChinese ? '连接' : 'Connect';
  String get disconnectDemo => isChinese ? '断开演示' : 'Disconnect';
  String get viewDemo => isChinese ? '查看演示' : 'View demo';
  String get connectAdapterFirst => isChinese ? '请先连接蓝牙、Wi‑Fi 或 USB 适配器' : 'Connect a Bluetooth, Wi-Fi, or USB adapter first';
  String get ecuFailed => isChinese ? '无法连接到车辆 ECU' : 'Unable to connect to ECU';
  String get disconnectEcuFirst => isChinese ? '请先断开车辆 ECU 连接' : 'Disconnect from the ECU first';

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('zh')];
  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode.toLowerCase());
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}
