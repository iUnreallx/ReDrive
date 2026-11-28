import 'package:flutter/foundation.dart';

import '../obd/session/obd_session.dart';
import 'obd_provider.dart';

enum DtcState { idle, loading, clearing, success, error, clearFailed }

class DtcProvider extends ChangeNotifier {
  final ObdProvider _obd;
  ObdSession? _session;

  DtcProvider(this._obd) : _session = _obd.diagnosticsSession {
    _obd.addListener(_syncSession);
  }

  bool get canScan => _session != null && !isBusy;
  bool get canClear =>
      canScan && _state == DtcState.success && _codes.isNotEmpty;
  ObdSession? get session => _session;
  bool get connected => _session != null;

  void _syncSession() {
    final session = _obd.diagnosticsSession;
    if (identical(_session, session)) return;
    _session = session;
    _codes = const [];
    _error = null;
    _checkedAt = null;
    _state = DtcState.idle;
    notifyListeners();
  }

  DateTime? _checkedAt;

  DateTime? get checkedAt => _checkedAt;

  DtcState _state = DtcState.idle;
  DtcState get state => _state;

  List<String> _codes = const [];
  List<String> get codes => _codes;

  Object? _error;
  Object? get error => _error;

  bool get isBusy => _state == DtcState.loading || _state == DtcState.clearing;

  Future<void> clearCodes() async {
    final session = _session;
    if (session == null || !canClear) return;
    _state = DtcState.clearing;
    _error = null;
    notifyListeners();

    try {
      await _obd.clearStoredCodes();
    } catch (error) {
      if (_session != session) return;
      _error = error;
      _state = DtcState.clearFailed;
      notifyListeners();
      return;
    }
    if (_session == session) await _loadCodes(session);
  }

  Future<void> loadCodes() async {
    final session = _session;
    if (session == null || !canScan) return;
    await _loadCodes(session);
  }

  Future<void> _loadCodes(ObdSession session) async {
    _state = DtcState.loading;
    _error = null;
    notifyListeners();

    try {
      final codes = await _obd.readStoredCodes();
      if (_session != session) return;
      _codes = codes;
      _checkedAt = DateTime.now();
      _state = DtcState.success;
      notifyListeners();
    } catch (error) {
      if (_session != session) return;
      _error = error;
      _state = DtcState.error;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _obd.removeListener(_syncSession);
    _session = null;
    super.dispose();
  }
}
