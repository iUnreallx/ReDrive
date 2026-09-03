import '../pid/pid_definition.dart';
import '../pid/pid_key.dart';
import '../pid/pid_registry.dart';

enum PollingDemandSource {
  visibleScreen,
  backgroundMonitoring,
  logging,
  session,
}

class PollingController {
  final PidRegistry _registry;
  final Set<PidKey> _supportedEcuKeys;

  final Map<PollingDemandSource, Set<PidKey>> _demands = {};

  PollingController({
    required PidRegistry registry,
    required Set<PidKey> supportedEcuKeys,
  }) : _registry = registry,
       _supportedEcuKeys = supportedEcuKeys;

  void updateDemand(PollingDemandSource source, Set<PidKey> keys) {
    if (keys.isEmpty) {
      _demands.remove(source);
    } else {
      _demands[source] = Set.unmodifiable(keys);
    }
  }

  Set<PidKey> computeEffectiveKeys() {
    final allRequested = <PidKey>{};
    for (final keys in _demands.values) {
      allRequested.addAll(keys);
    }

    final effective = <PidKey>{};
    for (final key in allRequested) {
      final definition = _registry.find(key);
      if (definition == null) continue;

      if (definition.source == PidSource.adapter ||
          _supportedEcuKeys.contains(key)) {
        effective.add(key);
      }
    }

    return effective;
  }
}
