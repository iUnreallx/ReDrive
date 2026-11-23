import 'package:flutter/foundation.dart';

enum DtcState { idle, loading, clearing, success, error, clearFailed }

class DtcProvider extends ChangeNotifier {
  final Future<List<String>> Function() _readStoredCodes;

  final Future<void> Function() _clearStoredCodes;

  DtcProvider({
    required Future<List<String>> Function() readStoredCodes,
    required Future<void> Function() clearStoredCodes,
  }) : _readStoredCodes = readStoredCodes,
       _clearStoredCodes = clearStoredCodes;

  DtcState _state = DtcState.idle;
  DtcState get state => _state;

  List<String> _codes = const [];
  List<String> get codes => _codes;

  Object? _error;
  Object? get error => _error;

  bool get isBusy => _state == DtcState.loading || _state == DtcState.clearing;

  Future<void> clearCodes() async {
    if (_state != DtcState.success || _codes.isEmpty) return;
    _state = DtcState.clearing;
    _error = null;
    notifyListeners();

    try {
      await _clearStoredCodes();
    } catch (error) {
      _error = error;
      _state = DtcState.clearFailed;
      notifyListeners();
      return;
    }
    await _loadCodes();
  }

  Future<void> loadCodes() async {
    if (isBusy) return;
    await _loadCodes();
  }

  Future<void> _loadCodes() async {
    _state = DtcState.loading;
    _error = null;
    notifyListeners();

    try {
      _codes = await _readStoredCodes();
      _state = DtcState.success;
      notifyListeners();
    } catch (error) {
      _error = error;
      _state = DtcState.error;
      notifyListeners();
    }
  }

  Future<void> clearStoredCodes() async {}
}
