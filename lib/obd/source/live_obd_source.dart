import 'dart:async';
import '../connection/obd_connection.dart';
import '../elm/elm_client.dart';
import '../pid/pid_key.dart';
import '../pid/pid_registry.dart';
import '../polling/polling_controller.dart';
import '../session/obd_session.dart';
import 'obd_source_state.dart';

/// Manages a live OBD - II data source.
///
/// Initializes the ELM327 session, discovers supported PID's,
/// manages polling, and forwards live PID updates.
///
/// OBD-level recovery is handled here.
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
  final Map<WatchSource, Set<PidKey>> _pendingWatchlists = {};

  bool _stopRequested = false;
  int _recoveryAttempts = 0;

  LiveObdSource({
    required ObdConnection connection,
    required PidRegistry registry,
  }) : _connection = connection,
       _registry = registry;

  ObdSourceState get state => _state;
  ObdSession? get session => _session;
  Stream<ObdSourceState> get stateStream => _stateController.stream;
  Set<PidKey> get supportedKeys => _supportedKeys;
  Stream<({PidKey key, num value})> get updates => _updatesController.stream;
  Map<PidKey, num> get latestValues =>
      _pollingController?.latestValues ?? const {};

  void setWatchlist(WatchSource source, Set<PidKey> keys) {
    if (keys.isEmpty) {
      _pendingWatchlists.remove(source);
    } else {
      _pendingWatchlists[source] = Set.unmodifiable(keys);
    }

    _pollingController?.setWatchlist(source, keys);
  }

  void clearWatchlist(WatchSource source) {
    setWatchlist(source, const {});
  }

  void _setState(ObdSourceState newState) {
    if (_state == newState) return;
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    _setState(ObdSourceState.disconnected);
    await _cleanupActiveComponents();
    _supportedKeys = const {};
  }

  Future<void> start() async {
    if (_stopRequested) return;

    if (_state != ObdSourceState.disconnected &&
        _state != ObdSourceState.error) {
      return;
    }

    try {
      _setState(ObdSourceState.connecting);
      _setState(ObdSourceState.initializing);

      await _startSession();
      if (_stopRequested) return;

      _setState(ObdSourceState.polling);
      _pollingController!.start();
    } catch (error, stackTrace) {
      if (_stopRequested) return;
      await _recoverSession(error, stackTrace);
    }
  }

  Future<void> _startSession() async {
    final client = ElmClient(connection: _connection);
    _elmClient = client;

    final session = ObdSession(elmClient: client);
    _session = session;

    final rawSupportedPids = await session.initialize();
    if (_stopRequested) return;

    _supportedKeys = _registry.findSupportedEcuKeys(rawSupportedPids);

    final controller = PollingController(
      elmClient: client,
      registry: _registry,
      supportedEcuKeys: _supportedKeys,
    );
    _pollingController = controller;

    for (final entry in _pendingWatchlists.entries) {
      controller.setWatchlist(entry.key, entry.value);
    }

    _pollingSubscription = controller.updates.listen(
      (data) {
        if (!_updatesController.isClosed) {
          _updatesController.add(data);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        unawaited(_recoverSession(error, stackTrace));
      },
    );
  }

  Future<void> _recoverSession(Object error, StackTrace stackTrace) async {
    if (_stopRequested || _state == ObdSourceState.recovering) return;

    var lastError = error;
    var lastStackTrace = stackTrace;

    _setState(ObdSourceState.recovering);

    while (_recoveryAttempts < 2) {
      if (_stopRequested) return;

      await _cleanupActiveComponents();
      if (_stopRequested) return;

      try {
        await _startSession();
        if (_stopRequested) return;

        _setState(ObdSourceState.polling);
        _pollingController!.start();
        return;
      } catch (newError, newStackTrace) {
        if (_stopRequested) return;

        lastError = newError;
        lastStackTrace = newStackTrace;
      }
    }

    await _cleanupActiveComponents();
    if (_stopRequested) return;

    _setState(ObdSourceState.error);

    if (!_updatesController.isClosed) {
      _updatesController.addError(lastError, lastStackTrace);
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

  Future<void> dispose() async {
    await stop();
    await _updatesController.close();
    await _stateController.close();
  }
}
