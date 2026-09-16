class BluetoothObdDevice {
  final String name;
  final String address;
  final bool isBle;

  const BluetoothObdDevice({
    required this.name,
    required this.address,
    this.isBle = false,
  });

  @override
  String toString() {
    return 'ObdDevice(name: $name, address: $address, isBle: $isBle)';
  }
}
