import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../obd/models/obd_data.dart';
import '../obd/connection/obd_connection.dart';
import '../services/demo/demo_data_generator.dart';

enum ObdConnectionState { disconnected, initializing, ready, error }

class ObdProvider extends ChangeNotifier {
  final ObdConnection currentConnection;
  late ObdConnection _connection;

  /// Добавляем стрим для одноразок ui событий
  final _errorEventController = StreamController<String>.broadcast();
  Stream<String> get errorEvents => _errorEventController.stream;

  /// Возвращает статус физического подключения
  /// Ble, wifi, usb, demo режим и другие
  bool get isDeviceConnected => _connection.isConnected;

  final DemoDataGenerator _demoGenerator = DemoDataGenerator();

  StreamSubscription<String>? _rxSubscription;

  Completer<String>? _commandCompleter;
  final StringBuffer _commandBuffer = StringBuffer();

  ObdConnectionState _state = ObdConnectionState.disconnected;
  ObdConnectionState get state => _state;

  ObdData _data = const ObdData();
  ObdData get data => _data;

  bool _isDemoMode = false;
  bool get isDemoMode => _isDemoMode;

  bool _isRealMode = false;
  bool get isRealMode => _isRealMode;

  String _initMessage = "Инициализация";
  String get initMessage => _initMessage;

  bool _prevIsConnected = false;
  bool _prevIsReconnecting = false;

  /// For debug    ///
  /// Для откладки ///
  set state(ObdConnectionState value) {
    if (_state == value) return;

    developer.log('🔄 СМЕНА СОСТОЯНИЯ: $_state -> $value', name: 'ObdProvider');

    _state = value;
    notifyListeners();
  }

  void updateConnection(ObdConnection newConnection) {
    _connection = newConnection;
    _listen();

    final currentIsConnected = _connection.isConnected;
    final currentIsReconnecting = _connection.isReconnecting;

    /// Определяем, был ли обрыв связи на предыдущем шаге
    /// (либо не было коннекта, либо шел процесс фонового переподключения)
    bool wasDisconnectedOrReconnecting =
        !_prevIsConnected || _prevIsReconnecting;

    /// Если включён реально,
    /// если в переподключался
    /// сейчас подключён и уже не переподключается
    /// то нам нужно заново востановить handshake ( рукопожатие)
    if (_isRealMode &&
        wasDisconnectedOrReconnecting &&
        currentIsConnected &&
        !currentIsReconnecting) {
      _recoverEcuConnection();
    }

    /// Если был включён человекм
    /// и сейчас уже не подключёен и
    /// не переподключается то стопаем
    /// значит подключение отвалилось не нашими силами
    if (_isRealMode && !currentIsConnected && !currentIsReconnecting) {
      stopRealData();
    }

    _prevIsConnected = currentIsConnected;
    _prevIsReconnecting = currentIsReconnecting;

    notifyListeners();
  }

  Future<void> _recoverEcuConnection() async {
    state = ObdConnectionState.initializing;

    developer.log(
      '🔄 Блютуз восстановлен. Ждем инициализации железа...',
      name: 'ObdProvider',
    );

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!_isRealMode) return;

    bool isSuccess = await runHandshake();

    if (!_isRealMode) return;

    if (isSuccess) {
      state = ObdConnectionState.ready;
    } else {
      stopWithError("Связь потеряна: не удалось переподключиться к ЭБУ");
    }
  }

  ObdProvider(this.currentConnection) {
    _connection = currentConnection;
    _listen();
  }

  void _listen() {
    _rxSubscription?.cancel();
    _rxSubscription = _connection.incoming.listen(_handleIncomingData);
  }

  /// ======= Парсинг ======== ///

  void _handleIncomingData(String rawData) {
    if (_isDemoMode) return;

    /// если режим демонстрации то мы
    /// просто отправялем пустой объект
    /// obdData и целиком обновляем его
    _commandBuffer.write(rawData);
    if (rawData.contains(">")) {
      if (_commandCompleter?.isCompleted == false) {
        _commandCompleter?.complete(_commandBuffer.toString());
      }
    }
  }

  /// получаем команду -> ставим новый обработчик "успешности"
  /// отправляем в текущее соединение команду и ждём ответ
  Future<String> _sendAndWait(String command) async {
    _commandBuffer.clear();
    _commandCompleter = Completer<String>();

    _connection.send("$command\r");

    try {
      return await _commandCompleter!.future.timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      developer.log("таймаут команды $command: $e", name: 'ObdLogic');
      return "";
    }
  }

  /// парсим значения от нашего текущего подключения, и возвращаем объект
  /// пакета данных если всё прошло корректно
  /// сейчас уже умеет парсить: скорость, обороты движка
  /// температуру движка и напряжение сети ( акб'шку )
  ObdData _parseResponse(String rawData, ObdData currentBatchData) {
    final cleanData = rawData.replaceAll('>', '').trim();

    if (cleanData.isEmpty ||
        cleanData == "OK" ||
        cleanData.contains("ELM327")) {
      return currentBatchData;
    }

    developer.log("⬇️ ОТВЕТ: $cleanData", name: 'ObdLogic');

    final parts = cleanData.split(RegExp(r'\s+'));

    try {
      /// скорость
      if (parts.length >= 3 && parts[0] == "41" && parts[1] == "0D") {
        return currentBatchData.copyWith(speed: int.parse(parts[2], radix: 16));

        /// обороты
      } else if (parts.length >= 4 && parts[0] == "41" && parts[1] == "0C") {
        final a = int.parse(parts[2], radix: 16);
        final b = int.parse(parts[3], radix: 16);
        return currentBatchData.copyWith(rpm: ((a * 256) + b) ~/ 4);

        /// температура
      } else if (parts.length >= 3 && parts[0] == "41" && parts[1] == "05") {
        return currentBatchData.copyWith(
          coolantTemp: int.parse(parts[2], radix: 16) - 40,
        );

        /// напряжение сети
      } else if (cleanData.contains('V')) {
        final voltValue = double.tryParse(cleanData.replaceAll('V', ''));
        if (voltValue != null) {
          return currentBatchData.copyWith(voltage: voltValue);
        }
      }
    } catch (e) {
      developer.log("ошибка парсинга: $e", name: 'ObdLogic');
    }

    return currentBatchData;
  }

  /// ======= REAL MODE ========= ///

  /// если у нас есть реальное подключенное устройство, то
  /// мы отправляем запросы "инициализации" и после этого крутим
  /// цикл обработки запросов от нашего elm327 по obd2 разьёму
  Future<void> toggleRealMode() async {
    if (!_connection.isConnected ||
        (_connection.isReconnecting && !isRealMode)) {
      return;
    }

    if (_isRealMode) {
      stopRealData();
      state = ObdConnectionState.disconnected;
      return;
    }

    if (_isDemoMode) {
      _isDemoMode = false;
      _demoGenerator.stop();
      _data = const ObdData();
      notifyListeners();
    }

    // _connection = currentConnection;
    // _listen();

    bool isSuccessHandshake = await runHandshake();

    if (state == ObdConnectionState.disconnected) {
      developer.log(
        'Инициализация была прервана пользователем',
        name: 'ObdProvider',
      );
      return;
    }

    if (isSuccessHandshake) {
      _isRealMode = true;
      state = ObdConnectionState.ready;
      _startPollingLoop();
    } else {
      state = ObdConnectionState.error;
    }
  }

  /// пакетно (дожидаясь каждого датчика) отправляем
  /// данные на obd2 через наше подключение
  /// и как дождёмся всех обновляем UI
  Future<void> _startPollingLoop() async {
    while (_isRealMode) {
      if (_connection.isReconnecting ||
          state == ObdConnectionState.initializing) {
        developer.log('Пауза опроса: Блютуз в реконнекте', name: 'ObdProvider');
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      if (!_connection.isConnected) {
        developer.log('Связь потеряна окончательно', name: 'ObdProvider');
        break;
      }

      ObdData batchData = _data;

      String speedRes = await _sendAndWait("010D");
      if (!_isRealMode || !_connection.isConnected) return;
      batchData = _parseResponse(speedRes, batchData);

      String rpmRes = await _sendAndWait("010C");
      if (!_isRealMode || !_connection.isConnected) return;
      batchData = _parseResponse(rpmRes, batchData);

      String tempRes = await _sendAndWait("0105");
      if (!_isRealMode || !_connection.isConnected) return;
      batchData = _parseResponse(tempRes, batchData);

      String voltRes = await _sendAndWait("ATRV");
      if (!_isRealMode || !_connection.isConnected) return;
      batchData = _parseResponse(voltRes, batchData);

      if (_isRealMode && _connection.isConnected) {
        _data = batchData;
        notifyListeners();
      }

      if (_isRealMode) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (_isRealMode) {
      developer.log('внезапный обрыв связи эбу', name: 'ObdProvider');
      stopRealData();
    }
  }

  void stopRealData() {
    if (state == ObdConnectionState.disconnected) return;

    _isRealMode = false;

    if (_commandCompleter?.isCompleted == false) {
      _commandCompleter?.complete("");
    }

    _data = const ObdData();
    state = ObdConnectionState.disconnected;
    notifyListeners();
  }

  void stopWithError(String errorMessage) {
    stopRealData();
    _errorEventController.add(errorMessage);
    notifyListeners();
  }

  /// ===== DEMO MODE =========

  Future<void> toggleDemoMode() async {
    if (_isRealMode) return;

    if (_isDemoMode) {
      _isDemoMode = false;
      _demoGenerator.stop();
      _data = const ObdData();
      notifyListeners();
      return;
    }

    _isDemoMode = true;

    _demoGenerator.start((ObdData newObdData) {
      _data = newObdData;
      notifyListeners();
    });

    notifyListeners();
  }

  /// рукопожатие или же просто инициализация, обязательна
  /// для всех obd2 разьёмов чтобы настроить всё на корректную работу
  /// с движком машины.
  Future<bool> runHandshake() async {
    try {
      state = ObdConnectionState.initializing;
      _initMessage = "Подключение к ЭБУ";
      notifyListeners();

      String atz = await _sendAndWait("ATZ");
      if (state == ObdConnectionState.disconnected) return false;
      if (!atz.toUpperCase().contains("ELM327")) return false;

      String ate0 = await _sendAndWait("ATE0");
      if (state == ObdConnectionState.disconnected) return false;
      if (!ate0.toUpperCase().contains("OK")) return false;

      String atl0 = await _sendAndWait("ATL0");
      if (state == ObdConnectionState.disconnected) return false;
      if (!atl0.toUpperCase().contains("OK")) return false;

      String atsp0 = await _sendAndWait("ATSP0");
      if (state == ObdConnectionState.disconnected) return false;
      if (!atsp0.toUpperCase().contains("OK")) return false;

      await Future.delayed(Duration(milliseconds: 300));

      return true;
    } catch (e) {
      _initMessage = "Ошибка инициализации";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _isRealMode = false;
    _demoGenerator.stop();
    _errorEventController.close();
    _rxSubscription?.cancel();
    super.dispose();
  }
}
