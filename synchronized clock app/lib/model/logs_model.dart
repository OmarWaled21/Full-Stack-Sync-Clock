// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class LogsModel {
  final String source;
  final DateTime? timeStamp;
  final String errorType;
  final String message;

  LogsModel({
    required this.source,
    required this.timeStamp,
    required this.errorType,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'source': source,
      'timestamp': timeStamp?.millisecondsSinceEpoch,
      'type': errorType,
      'message': message,
    };
  }

  factory LogsModel.fromMap(Map<String, dynamic> map) {
    return LogsModel(
      source: map['source'] ?? '',
      timeStamp: map['timestamp'] != null ? _parseDate(map['timestamp']) : null,
      errorType: map['type'] ?? '',
      message: map['message'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory LogsModel.fromJson(String source) =>
      LogsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  static DateTime _parseDate(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // نحاول نحوله من ISO string لتاريخ
      try {
        return DateTime.parse(value);
      } catch (_) {
        // محاولة أخيرة لو هو رقم جاي كـ String
        return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
      }
    } else {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}
