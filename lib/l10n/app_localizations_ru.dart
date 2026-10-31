// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Главная';

  @override
  String get dashboard => 'Приборы';

  @override
  String get connection => 'Подключение';

  @override
  String get garage => 'Гараж';

  @override
  String get dtc => 'Ошибки';

  @override
  String get speed => 'Скорость';

  @override
  String get rpm => 'Обороты';

  @override
  String get preparing => 'Подготовка к подключению...';

  @override
  String get connectingEcu => 'Подключение к ЭБУ...';

  @override
  String get initializing => 'Настройка ELM327...';

  @override
  String get connected => 'Подключено';

  @override
  String get recovering => 'Восстановление связи...';

  @override
  String get connectionError => 'Ошибка подключения';

  @override
  String get cancel => 'Отмена';

  @override
  String get settings => 'Настройки';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get wifi => 'Wi-Fi';

  @override
  String get usb => 'USB';

  @override
  String get usbDeveloping => 'Подключение по USB в разработке';

  @override
  String get bluetoothConnection => 'Подключение по Bluetooth';

  @override
  String get bluetoothDescription =>
      'Подключите адаптер OBD2, чтобы видеть\nданные автомобиля в реальном времени.';

  @override
  String get wifiConnection => 'Подключение по Wi-Fi';

  @override
  String get wifiDescription =>
      'Подключитесь к Wi-Fi сети адаптера,\nзатем введите его адрес.';

  @override
  String get ipAddress => 'IP-адрес';

  @override
  String get port => 'Порт';

  @override
  String get disconnect => 'Отключить';

  @override
  String get notConnected => 'Не подключено';

  @override
  String connectingTo(String target) {
    return 'Подключение к $target...';
  }

  @override
  String connectedTo(String target) {
    return 'Подключено к $target';
  }

  @override
  String get invalidAddress => 'Введите корректный IP-адрес и порт';

  @override
  String adapterNotResponding(String target) {
    return 'Нет ответа от $target';
  }

  @override
  String get startScanning => 'Начать поиск';

  @override
  String get scanning => 'Поиск...';

  @override
  String get scanningComplete => 'Поиск завершён';

  @override
  String get searchingAdapter => 'Ищем ваш адаптер...';

  @override
  String devicesFound(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Найдено $n устройства',
      many: 'Найдено $n устройств',
      few: 'Найдено $n устройства',
      one: 'Найдено $n устройство',
    );
    return '$_temp0';
  }

  @override
  String get permissionTitle => 'Нужен доступ к Bluetooth';

  @override
  String get permissionDescription =>
      'Доступ к Bluetooth запрещён навсегда. Включите его в настройках приложения.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get garageTitle => 'Мой гараж';

  @override
  String get garageDescription => 'Здесь появятся ваши автомобили';

  @override
  String get noVehicles => 'Нет автомобилей';

  @override
  String get addFirstVehicle => 'Добавьте свой первый\nавтомобиль';

  @override
  String get addVehicle => 'Добавить автомобиль';

  @override
  String get vehicleConnected => 'Автомобиль подключён';

  @override
  String get connect => 'Подключить';

  @override
  String get disconnectDemo => 'Отключить';

  @override
  String get viewDemo => 'Посмотреть демо';

  @override
  String get connectAdapterFirst =>
      'Сначала подключите адаптер Bluetooth, Wi-Fi или USB';

  @override
  String get ecuFailed => 'Не удалось подключиться к ЭБУ';

  @override
  String get disconnectEcuFirst => 'Сначала отключитесь от ЭБУ';

  @override
  String get bannerRestoring => 'Восстановление связи';

  @override
  String get bannerReconnecting => 'Переподключение';

  @override
  String get reconnectWait => 'Переподключение, подождите';

  @override
  String get connectionLost => 'Связь потеряна. Подключитесь снова';
}
