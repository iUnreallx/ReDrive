import 'dart:async';
import 'dart:math';
import '../../obd/models/obd_data.dart';

class DemoDataGenerator {
  Timer? _timer;
  final _random = Random();

  void start(Function(ObdData) onData) {
    stop();

    onData(_generateData());

    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      onData(_generateData());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  ObdData _generateData() {
    return ObdData(
      speed: 30 + _random.nextInt(270), // от 0 до 300 км/ч
      rpm: 800 + _random.nextInt(14000), // от 800 до 14799 об/мин
      coolantTemp: 30 + _random.nextInt(80), // от 30 до 109 °C
      voltage: 13.0 + (_random.nextDouble() * 2.5), // от 13.0 до 15.5 V
    );
  }
}
