import 'package:flutter/widgets.dart';

/// App strings selected from the system locale.
/// zh-SG and other zh-* locales default to Simplified Chinese, while
/// zh-HK, zh-MO, zh-TW, and zh-Hant use Traditional Chinese.
class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  bool get isChinese => locale.languageCode.toLowerCase() == 'zh';
  bool get isTraditionalChinese {
    if (!isChinese) return false;
    final region = (locale.countryCode ?? '').toUpperCase();
    final script = (locale.scriptCode ?? '').toLowerCase();
    return script == 'hant' || region == 'HK' || region == 'MO' || region == 'TW';
  }

  String _text(String simplified, String traditional, String english) {
    if (!isChinese) return english;
    return isTraditionalChinese ? traditional : simplified;
  }

  String get home => _text('主页', '首頁', 'Home');
  String get dashboard => _text('仪表盘', '儀表板', 'Dashboard');
  String get connection => _text('连接', '連線', 'Connection');
  String get garage => _text('车库', '車庫', 'Garage');
  String get dtc => _text('故障码', '故障碼', 'DTC');
  String get speed => _text('车速', '車速', 'Speed');
  String get rpm => _text('转速', '轉速', 'RPM');
  String get preparing => _text('准备连接...', '準備連線...', 'Preparing connection...');
  String get connectingEcu => _text('正在连接车辆 ECU...', '正在連線車輛 ECU...', 'Connecting to ECU...');
  String get initializing => _text('正在初始化 ELM327...', '正在初始化 ELM327...', 'Initializing ELM327...');
  String get connected => _text('已连接', '已連線', 'Connected');
  String get recovering => _text('正在恢复连接...', '正在恢復連線...', 'Recovering connection...');
  String get connectionError => _text('连接错误', '連線錯誤', 'Connection error');
  String get cancel => _text('取消', '取消', 'Cancel');
  String get settings => _text('设置', '設定', 'Settings');
  String get bluetooth => _text('蓝牙', '藍牙', 'Bluetooth');
  String get wifi => _text('无线网络', '無線網路', 'Wi-Fi');
  String get usb => 'USB';
  String get wifiDeveloping => _text('Wi‑Fi 连接功能正在开发中', 'Wi‑Fi 連線功能正在開發中', 'Wi-Fi connection is under development');
  String get usbDeveloping => _text('USB 连接功能正在开发中', 'USB 連線功能正在開發中', 'USB connection is under development');
  String get bluetoothConnection => _text('蓝牙连接', '藍牙連線', 'Bluetooth Connection');
  String get bluetoothDescription => _text('连接 OBD2 适配器后，\n即可查看车辆实时数据。', '連接 OBD2 適配器後，\n即可查看車輛即時資料。', 'Connect your OBD2 adapter to see\nreal-time vehicle data.');
  String get startScanning => _text('开始扫描', '開始掃描', 'Start Scanning');
  String get scanning => _text('扫描中...', '掃描中...', 'Scanning...');
  String get scanningComplete => _text('扫描完成', '掃描完成', 'Scanning complete');
  String get searchingAdapter => _text('正在搜索适配器...', '正在搜尋適配器...', 'Searching for your adapter...');
  String devicesFound(int n) => _text('发现 $n 个设备', '找到 $n 個裝置', 'Found $n devices');
  String get permissionTitle => _text('蓝牙权限不足', '藍牙權限不足', 'Bluetooth access required');
  String get permissionDescription => _text('蓝牙权限已被永久拒绝，请前往系统设置开启。', '藍牙權限已被永久拒絕，請前往系統設定開啟。', 'Bluetooth permission was permanently denied. Please enable it from app settings.');
  String get openSettings => _text('打开设置', '開啟設定', 'Open settings');
  String get garageTitle => _text('我的车库', '我的車庫', 'My Garage');
  String get garageDescription => _text('这里将显示你的车辆', '這裡將顯示你的車輛', 'Your vehicles will appear here');
  String get noVehicles => _text('暂无车辆', '暫無車輛', 'No vehicles');
  String get addFirstVehicle => _text('添加你的第一辆\n汽车', '新增你的第一輛\n汽車', 'Add your first\nvehicle');
  String get addVehicle => _text('添加车辆', '新增車輛', 'Add vehicle');
  String get vehicleConnected => _text('车辆已连接', '車輛已連線', 'Vehicle is connected');
  String get connect => _text('连接', '連線', 'Connect');
  String get disconnectDemo => _text('断开演示', '中斷示範', 'Disconnect');
  String get viewDemo => _text('查看演示', '查看示範', 'View demo');
  String get connectAdapterFirst => _text('请先连接蓝牙、Wi‑Fi 或 USB 适配器', '請先連接藍牙、Wi‑Fi 或 USB 適配器', 'Connect a Bluetooth, Wi-Fi, or USB adapter first');
  String get ecuFailed => _text('无法连接到车辆 ECU', '無法連線到車輛 ECU', 'Unable to connect to ECU');
  String get disconnectEcuFirst => _text('请先断开车辆 ECU 连接', '請先中斷車輛 ECU 連線', 'Disconnect from the ECU first');

  static const delegate = _AppLocalizationsDelegate();
  static const supportedLocales = [Locale('en'), Locale('zh'), Locale('zh', 'SG'), Locale('zh', 'HK'), Locale('zh', 'MO'), Locale('zh', 'TW')];
  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override bool isSupported(Locale locale) => locale.languageCode.toLowerCase() == 'en' || locale.languageCode.toLowerCase() == 'zh';
  @override Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);
  @override bool shouldReload(_AppLocalizationsDelegate old) => false;
}
