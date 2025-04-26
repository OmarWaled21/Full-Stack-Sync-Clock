import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothRepo {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  StreamSubscription<BluetoothDiscoveryResult>? _discoveryStream;
  List<BluetoothDevice> devices = [];
  BluetoothConnection? connection;

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();
  }

  initialize() async => await requestPermissions();

  Future<List<BluetoothDevice>> scanDevices({int timeoutSeconds = 5}) async {
    devices = [];
    final completer = Completer<List<BluetoothDevice>>();

    try {
      _discoveryStream = _bluetooth.startDiscovery().listen((result) {
        if (result.device.name?.contains("ESP32") ?? false) {
          if (!devices.any((d) => d.address == result.device.address)) {
            devices.add(result.device);
          }
        }
      });

      _discoveryStream!.onDone(() => completer.complete(devices));
      await Future.delayed(Duration(seconds: timeoutSeconds));
      await _discoveryStream?.cancel();
      return devices;
    } catch (e) {
      completer.completeError(e);
      return [];
    }
  }

  Future<BluetoothConnection> connectToDevice(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
    return connection!;
  }

  Future<void> sendWiFiCredentials(String ssid, String password, String token) async {
    if (connection == null || !connection!.isConnected) {
      throw Exception("Device not connected");
    }

    final message = '$ssid\n$password\n$token\n';
    connection!.output.add(Uint8List.fromList(utf8.encode(message)));
    await connection!.output.allSent;
  }

  Future<String> listenForDeviceId() async {
    if (connection == null || !connection!.isConnected) {
      throw Exception("Not connected to any device");
    }

    final completer = Completer<String>();
    String buffer = "";

    connection!.input?.listen(
      (Uint8List data) {
        final chunk = utf8.decode(data);
        buffer += chunk;
        print('Received chunk: $chunk');

        if (buffer.contains('\n')) {
          final line = buffer.split('\n').first.trim(); // خد أول سطر
          print('Parsed line: $line');
          completer.complete(line);
        }
      },
      onError: (err) {
        print('Error: $err');
        completer.completeError(err);
      },
    );

    return completer.future;
  }

  void dispose() {
    _discoveryStream?.cancel();
    connection?.dispose();
  }
}
