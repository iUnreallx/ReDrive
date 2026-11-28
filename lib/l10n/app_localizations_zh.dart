// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get dtcClearing => '正在清除故障码…';

  @override
  String get dtcClearFailed => '未确认清除结果，请重新扫描。';

  @override
  String get dtcClearTitle => '清除已存储的故障码？';

  @override
  String get dtcClearBody => '这会重置车辆的诊断数据。重置后，ReDrive 将重新读取故障码。';

  @override
  String get dtcScan => '读取故障码';

  @override
  String get dtcRescan => '重新扫描';

  @override
  String get dtcStored => '已存储故障码';

  @override
  String get dtcPending => '待定';

  @override
  String get dtcPermanent => '永久';

  @override
  String get dtcConfirmed => '已确认';

  @override
  String get dtcIdle => '准备读取';

  @override
  String get dtcLoading => '正在读取…';

  @override
  String get dtcEmpty => '没有已存储的故障码';

  @override
  String get dtcFailure => '无法读取故障码';

  @override
  String get dtcUnsupported => '不支持此协议';

  @override
  String get dtcClear => '清除故障码';

  @override
  String get dtcConnectTitle => '连接适配器';

  @override
  String get dtcConnectBody => '将 ELM327 插入方向盘下方的 OBD 接口，并打开点火开关。';

  @override
  String get dtcScanTitle => '检查车辆';

  @override
  String get dtcScanBody => '适配器已连接。读取只需几秒钟，无需启动发动机。';

  @override
  String get dtcKeepIgnition => '请保持点火开关打开';

  @override
  String dtcCheckedAt(String time) {
    return '检查时间 $time';
  }

  @override
  String dtcCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 个故障码',
    );
    return '$_temp0';
  }

  @override
  String get dtcAllGood => '控制单元中没有存储的故障码';

  @override
  String get home => '主页';

  @override
  String get dashboard => '仪表盘';

  @override
  String get connection => '连接';

  @override
  String get garage => '车库';

  @override
  String get dtc => '故障码';

  @override
  String get speed => '车速';

  @override
  String get rpm => '转速';

  @override
  String get preparing => '准备连接...';

  @override
  String get connectingEcu => '正在连接车辆 ECU...';

  @override
  String get initializing => '正在初始化 ELM327...';

  @override
  String get connected => '已连接';

  @override
  String get recovering => '正在恢复连接...';

  @override
  String get connectionError => '连接错误';

  @override
  String get cancel => '取消';

  @override
  String get settings => '设置';

  @override
  String get bluetooth => '蓝牙';

  @override
  String get wifi => '无线网络';

  @override
  String get usb => 'USB';

  @override
  String get usbDeveloping => 'USB 连接功能正在开发中';

  @override
  String get bluetoothConnection => '蓝牙连接';

  @override
  String get bluetoothDescription => '连接 OBD2 适配器后，\n即可查看车辆实时数据。';

  @override
  String get wifiConnection => 'Wi‑Fi 连接';

  @override
  String get wifiDescription => '请先连接适配器的 Wi‑Fi 网络，\n然后输入其地址。';

  @override
  String get ipAddress => 'IP 地址';

  @override
  String get port => '端口';

  @override
  String get disconnect => '断开连接';

  @override
  String get notConnected => '未连接';

  @override
  String connectingTo(String target) {
    return '正在连接 $target...';
  }

  @override
  String connectedTo(String target) {
    return '已连接到 $target';
  }

  @override
  String get invalidAddress => '请输入有效的 IP 地址和端口';

  @override
  String adapterNotResponding(String target) {
    return '$target 无响应';
  }

  @override
  String get startScanning => '开始扫描';

  @override
  String get scanning => '扫描中...';

  @override
  String get scanningComplete => '扫描完成';

  @override
  String get searchingAdapter => '正在搜索适配器...';

  @override
  String devicesFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '发现 $n 个设备',
    );
    return '$_temp0';
  }

  @override
  String get permissionTitle => '蓝牙权限不足';

  @override
  String get permissionDescription => '蓝牙权限已被永久拒绝，请前往系统设置开启。';

  @override
  String get openSettings => '打开设置';

  @override
  String get garageTitle => '我的车库';

  @override
  String get garageDescription => '这里将显示你的车辆';

  @override
  String get noVehicles => '暂无车辆';

  @override
  String get addFirstVehicle => '添加你的第一辆\n汽车';

  @override
  String get addVehicle => '添加车辆';

  @override
  String get vehicleConnected => '车辆已连接';

  @override
  String get connect => '连接';

  @override
  String get disconnectDemo => '断开演示';

  @override
  String get viewDemo => '查看演示';

  @override
  String get connectAdapterFirst => '请先连接蓝牙、Wi‑Fi 或 USB 适配器';

  @override
  String get ecuFailed => '无法连接到车辆 ECU';

  @override
  String get disconnectEcuFirst => '请先断开车辆 ECU 连接';

  @override
  String get bannerRestoring => '正在恢复连接';

  @override
  String get bannerReconnecting => '正在重新连接';

  @override
  String get reconnectWait => '正在重新连接，请稍候';

  @override
  String get connectionLost => '连接已断开，请重新连接';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get dtcClearing => '正在清除故障碼…';

  @override
  String get dtcClearFailed => '未確認清除結果，請重新掃描。';

  @override
  String get dtcClearTitle => '清除已儲存的故障碼？';

  @override
  String get dtcClearBody => '這會重設車輛的診斷資料。重設後，ReDrive 將重新讀取故障碼。';

  @override
  String get dtcScan => '讀取故障碼';

  @override
  String get dtcRescan => '重新掃描';

  @override
  String get dtcStored => '已儲存故障碼';

  @override
  String get dtcPending => '待定';

  @override
  String get dtcPermanent => '永久';

  @override
  String get dtcConfirmed => '已確認';

  @override
  String get dtcIdle => '準備讀取';

  @override
  String get dtcLoading => '正在讀取…';

  @override
  String get dtcEmpty => '沒有已儲存的故障碼';

  @override
  String get dtcFailure => '無法讀取故障碼';

  @override
  String get dtcUnsupported => '不支援此協定';

  @override
  String get dtcClear => '清除故障碼';

  @override
  String get dtcConnectTitle => '連接轉接器';

  @override
  String get dtcConnectBody => '將 ELM327 插入方向盤下方的 OBD 接口，並打開點火開關。';

  @override
  String get dtcScanTitle => '檢查車輛';

  @override
  String get dtcScanBody => '轉接器已連接。讀取只需幾秒鐘，無需啟動引擎。';

  @override
  String get dtcKeepIgnition => '請保持點火開關開啟';

  @override
  String dtcCheckedAt(String time) {
    return '檢查時間 $time';
  }

  @override
  String dtcCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n 個故障碼',
    );
    return '$_temp0';
  }

  @override
  String get dtcAllGood => '控制單元中沒有儲存的故障碼';

  @override
  String get home => '首頁';

  @override
  String get dashboard => '儀表板';

  @override
  String get connection => '連線';

  @override
  String get garage => '車庫';

  @override
  String get dtc => '故障碼';

  @override
  String get speed => '車速';

  @override
  String get rpm => '轉速';

  @override
  String get preparing => '準備連線...';

  @override
  String get connectingEcu => '正在連線車輛 ECU...';

  @override
  String get initializing => '正在初始化 ELM327...';

  @override
  String get connected => '已連線';

  @override
  String get recovering => '正在恢復連線...';

  @override
  String get connectionError => '連線錯誤';

  @override
  String get cancel => '取消';

  @override
  String get settings => '設定';

  @override
  String get bluetooth => '藍牙';

  @override
  String get wifi => '無線網路';

  @override
  String get usb => 'USB';

  @override
  String get usbDeveloping => 'USB 連線功能正在開發中';

  @override
  String get bluetoothConnection => '藍牙連線';

  @override
  String get bluetoothDescription => '連接 OBD2 適配器後，\n即可查看車輛即時資料。';

  @override
  String get wifiConnection => 'Wi‑Fi 連線';

  @override
  String get wifiDescription => '請先連接適配器的 Wi‑Fi 網路，\n然後輸入其位址。';

  @override
  String get ipAddress => 'IP 位址';

  @override
  String get port => '連接埠';

  @override
  String get disconnect => '中斷連線';

  @override
  String get notConnected => '未連線';

  @override
  String connectingTo(String target) {
    return '正在連線 $target...';
  }

  @override
  String connectedTo(String target) {
    return '已連線到 $target';
  }

  @override
  String get invalidAddress => '請輸入有效的 IP 位址和連接埠';

  @override
  String adapterNotResponding(String target) {
    return '$target 無回應';
  }

  @override
  String get startScanning => '開始掃描';

  @override
  String get scanning => '掃描中...';

  @override
  String get scanningComplete => '掃描完成';

  @override
  String get searchingAdapter => '正在搜尋適配器...';

  @override
  String devicesFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '找到 $n 個裝置',
    );
    return '$_temp0';
  }

  @override
  String get permissionTitle => '藍牙權限不足';

  @override
  String get permissionDescription => '藍牙權限已被永久拒絕，請前往系統設定開啟。';

  @override
  String get openSettings => '開啟設定';

  @override
  String get garageTitle => '我的車庫';

  @override
  String get garageDescription => '這裡將顯示你的車輛';

  @override
  String get noVehicles => '暫無車輛';

  @override
  String get addFirstVehicle => '新增你的第一輛\n汽車';

  @override
  String get addVehicle => '新增車輛';

  @override
  String get vehicleConnected => '車輛已連線';

  @override
  String get connect => '連線';

  @override
  String get disconnectDemo => '中斷示範';

  @override
  String get viewDemo => '查看示範';

  @override
  String get connectAdapterFirst => '請先連接藍牙、Wi‑Fi 或 USB 適配器';

  @override
  String get ecuFailed => '無法連線到車輛 ECU';

  @override
  String get disconnectEcuFirst => '請先中斷車輛 ECU 連線';

  @override
  String get bannerRestoring => '正在恢復連線';

  @override
  String get bannerReconnecting => '正在重新連線';

  @override
  String get reconnectWait => '正在重新連線，請稍候';

  @override
  String get connectionLost => '連線已中斷，請重新連線';
}
