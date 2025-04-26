import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SlaveClockModel {
  final String deviceId;
  final String? name;
  final String status;
  final double? temperature;
  final int? wifiStrength;
  final int? batteryLevel;
  final bool? rtcError;
  final bool? sensorError;
  final bool? lowBattery;
  final DateTime? lastUpdate;
  final double? maxTempThreshold;
  final double? minTempThreshold;
  final String? firmwareVersion;
  final String? firmwareUrl;
  final DateTime? lastCalibration;

  SlaveClockModel({
    required this.deviceId,
    required this.name,
    required this.status,
    required this.temperature,
    required this.wifiStrength,
    required this.batteryLevel,
    required this.rtcError,
    required this.sensorError,
    required this.lowBattery,
    required this.lastUpdate,
    required this.maxTempThreshold,
    required this.minTempThreshold,
    required this.firmwareVersion,
    required this.firmwareUrl,
    required this.lastCalibration,
  });

  SlaveClockModel copyWith({
    String? deviceId,
    String? name,
    String? status,
    double? temperature,
    int? wifiStrength,
    int? batteryLevel,
    bool? rtcError,
    bool? sensorError,
    bool? lowBattery,
    DateTime? lastUpdate,
    double? maxTempThreshold,
    double? minTempThreshold,
    String? firmwareVersion,
    String? firmwareUrl,
    DateTime? lastCalibration,
  }) {
    return SlaveClockModel(
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      wifiStrength: wifiStrength ?? this.wifiStrength,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      rtcError: rtcError ?? this.rtcError,
      sensorError: sensorError ?? this.sensorError,
      lowBattery: lowBattery ?? this.lowBattery,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      maxTempThreshold: maxTempThreshold ?? this.maxTempThreshold,
      minTempThreshold: minTempThreshold ?? this.minTempThreshold,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      firmwareUrl: firmwareUrl ?? this.firmwareUrl,
      lastCalibration: lastCalibration ?? this.lastCalibration,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'device_id': deviceId,
      'name': name,
      'status': status,
      'temperature': temperature,
      'wifi_strength': wifiStrength,
      'battery_level': batteryLevel,
      'rtc_error': rtcError,
      'sensor_error': sensorError,
      'low_battery': lowBattery,
      'last_update': lastUpdate?.millisecondsSinceEpoch,
      'temperature_max_threshold': maxTempThreshold,
      'temperature_min_threshold': minTempThreshold,
      'firmware_version': firmwareVersion,
      'firmware_url': firmwareUrl,
      'last_calibrated': lastCalibration?.millisecondsSinceEpoch,
    };
  }

  factory SlaveClockModel.fromMap(Map<String, dynamic> map) {
    return SlaveClockModel(
      deviceId: map['device_id'] ?? '',
      name: map['name'],
      status: map['status'] ?? 'unknown',
      temperature: (map['temperature'] != null) ? (map['temperature'] as num).toDouble() : null,
      wifiStrength: map['wifi_strength'],
      batteryLevel: map['battery_level'],
      rtcError: map['rtc_error'],
      sensorError: map['sensor_error'],
      lowBattery: map['low_battery'],
      lastUpdate: map['last_update'] != null ? DateTime.parse(map['last_update']) : null,
      maxTempThreshold:
          (map['temperature_max_threshold'] != null)
              ? (map['temperature_max_threshold'] as num).toDouble()
              : null,
      minTempThreshold:
          (map['temperature_min_threshold'] != null)
              ? (map['temperature_min_threshold'] as num).toDouble()
              : null,

      firmwareVersion: map['firmware_version'] ?? '',
      firmwareUrl: map['firmware_url'] ?? '',
      lastCalibration:
          map['last_calibrated'] != null ? DateTime.parse(map['last_calibrated']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SlaveClockModel.fromJson(String source) =>
      SlaveClockModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
