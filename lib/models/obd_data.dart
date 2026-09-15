class ObdData {
  final int rpm;
  final int speed;
  final int coolantTemp;
  final double voltage;

  const ObdData({
    this.rpm = 0,
    this.speed = 0,
    this.coolantTemp = 0,
    this.voltage = 0.0,
  });

  ObdData copyWith({int? rpm, int? speed, int? coolantTemp, double? voltage}) {
    return ObdData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      voltage: voltage ?? this.voltage,
    );
  }

  @override
  String toString() {
    return 'ObdData('
        'rpm: $rpm, '
        'speed: $speed km/h, '
        'coolantTemp: $coolantTemp°C, '
        'voltage: $voltage V'
        ')';
  }
}
