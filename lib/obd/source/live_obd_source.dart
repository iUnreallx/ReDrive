import 'dart:async';
import '../../services/obd_connection.dart';
import '../elm/elm_client.dart';
import '../pid/pid_key.dart';
import '../pid/pid_registry.dart';
import '../polling/polling_controller.dart';
import '../session/obd_session.dart';
import 'obd_source_state.dart';

class LiveObdSource {
  final ObdConnection _connection;
  final PidRegistry _registry;

  ElmClient? _elmClient;
  ObdSession? _session;
  PollingController? _pollingController;

  ObdSourceState _state = ObdSourceState.disconnected;
  final _stateController = StreamController<ObdSourceState>.broadcast();

  final _updatesController =
      StreamController<({PidKey key, num value})>.broadcast();
  StreamSubscription<({PidKey key, num value})>? _pollingSubscription;

  Set<PidKey> _supportedKeys = const {};
  Set<PidKey> _pendingScreenDemand = const {};

  LiveObdSource({
    required ObdConnection connection,
    required PidRegistry registry,
  }) : _connection = connection,
       _registry = registry;

  ObdSourceState get state => _state;
  Stream<ObdSourceState> get stateStream => _stateController.stream;
  Set<PidKey> get supportedKeys => _supportedKeys;
  Stream<({PidKey key, num value})> get updates => _updatesController.stream;

  Map<PidKey, num> get latestValues =>
      _pollingController?.latestValues ?? const {};

  void setScreenDemand(Set<PidKey> keys) {
    _pendingScreenDemand = Set.unmodifiable(keys);

    _pollingController?.updateDemand(
      PollingDemandSource.visibleScreen,
      _pendingScreenDemand,
    );
  }

  void _setState(ObdSourceState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> _cleanupActiveComponents() async {
    await _pollingSubscription?.cancel();
    _pollingSubscription = null;

    await _pollingController?.dispose();
    _pollingController = null;

    await _elmClient?.dispose();
    _elmClient = null;

    _session = null;
  }

  Future<void> stop() async {
    await _cleanupActiveComponents();
    _supportedKeys = const {};
    _setState(ObdSourceState.disconnected);
  }

  Future<void> start() async {
    if (_state != ObdSourceState.disconnected &&
        _state != ObdSourceState.error) {
      return;
    }

    try {
      _setState(ObdSourceState.connecting);

      final client = ElmClient(connection: _connection);
      _elmClient = client;

      _setState(ObdSourceState.initializing);

      final session = ObdSession(elmClient: client);
      _session = session;

      final rawSupportedPids = await session.initialize();
      _supportedKeys = _registry.findSupportedEcuKeys(rawSupportedPids);

      final controller = PollingController(
        elmClient: client,
        registry: _registry,
        supportedEcuKeys: _supportedKeys,
      );
      _pollingController = controller;

      if (_pendingScreenDemand.isNotEmpty) {
        controller.updateDemand(
          PollingDemandSource.visibleScreen,
          _pendingScreenDemand,
        );
      }

      _pollingSubscription = controller.updates.listen(
        (data) {
          if (!_updatesController.isClosed) {
            _updatesController.add(data);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!_updatesController.isClosed) {
            _updatesController.addError(error, stackTrace);
          }

          _setState(ObdSourceState.error);

          unawaited(_cleanupActiveComponents());
        },
      );

      controller.start();
      _setState(ObdSourceState.polling);
    } catch (_) {
      _setState(ObdSourceState.error);
      await _cleanupActiveComponents();
    }
  }

  Future<void> dispose() async {
    await stop();
    await _updatesController.close();
    await _stateController.close();
  }
}
