// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(bat) => "Battery level is low. ${bat}%";

  static String m1(temp) =>
      "Temperature sensor malfunction. Current temperature: ${temp}°C";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "NoLogsAvailable": MessageLookupByLibrary.simpleMessage(
      "No logs available.",
    ),
    "addAccount": MessageLookupByLibrary.simpleMessage("Add Account"),
    "addDevice": MessageLookupByLibrary.simpleMessage("Add Device"),
    "addNewDevice": MessageLookupByLibrary.simpleMessage("Add New Device"),
    "add_user": MessageLookupByLibrary.simpleMessage("Add User"),
    "batteryLevel": MessageLookupByLibrary.simpleMessage("Battery Level"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "clockName": MessageLookupByLibrary.simpleMessage("Clock Name"),
    "clockStatus": MessageLookupByLibrary.simpleMessage("Clock Status"),
    "confirmDeleteClock": MessageLookupByLibrary.simpleMessage(
      "Are you sure deleting this clock?",
    ),
    "deleteClock": MessageLookupByLibrary.simpleMessage("Delete Clock"),
    "deviceOverview": MessageLookupByLibrary.simpleMessage("Device Overview"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editMasterClock": MessageLookupByLibrary.simpleMessage(
      "Edit Master Clock",
    ),
    "edit_time": MessageLookupByLibrary.simpleMessage("Edit Time"),
    "email": MessageLookupByLibrary.simpleMessage("Email"),
    "enableSendMessagesSms": MessageLookupByLibrary.simpleMessage(
      "Enable Send Messages SMS",
    ),
    "enableSendMessagesToGmail": MessageLookupByLibrary.simpleMessage(
      "Enable Send Messages To Gmail",
    ),
    "enableSendMessagesToWhatsApp": MessageLookupByLibrary.simpleMessage(
      "Enable Send Messages To WhatsApp",
    ),
    "enter": MessageLookupByLibrary.simpleMessage("Enter"),
    "enterWifiCredentials": MessageLookupByLibrary.simpleMessage(
      "Enter Wifi Credentials",
    ),
    "error": MessageLookupByLibrary.simpleMessage("Error"),
    "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
    "forgotPassword": MessageLookupByLibrary.simpleMessage("Forgot Password?"),
    "good": MessageLookupByLibrary.simpleMessage("Good"),
    "grayDisconnected": MessageLookupByLibrary.simpleMessage(
      "Gray (Disconnected)",
    ),
    "greenOk": MessageLookupByLibrary.simpleMessage("Green (OK)"),
    "groupUrl": MessageLookupByLibrary.simpleMessage("Whatsapp Group Url"),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageCode": MessageLookupByLibrary.simpleMessage("en"),
    "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
    "lastUpdate": MessageLookupByLibrary.simpleMessage("Last Update"),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginSuccessful": MessageLookupByLibrary.simpleMessage(
      "Login successful. Welcome back!",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logs": MessageLookupByLibrary.simpleMessage("Logs"),
    "lowBattery": MessageLookupByLibrary.simpleMessage("Low Battery"),
    "lowBatteryMessage": m0,
    "master_clock": MessageLookupByLibrary.simpleMessage("Master Clock"),
    "max": MessageLookupByLibrary.simpleMessage("Max"),
    "messageSmsDectionary": MessageLookupByLibrary.simpleMessage(
      "If you enable this option, you must enter your phone number to receive notifications in SMS.",
    ),
    "messageWhatsappDectionary": MessageLookupByLibrary.simpleMessage(
      "If you enable this option, you must enter the WhatsApp group link to receive notifications.",
    ),
    "messagegmailDectionary": MessageLookupByLibrary.simpleMessage(
      "If you enable this option, you must enter your email to receive notifications.",
    ),
    "messages": MessageLookupByLibrary.simpleMessage("Messages"),
    "min": MessageLookupByLibrary.simpleMessage("Min"),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noDevicesFound": MessageLookupByLibrary.simpleMessage("No devices found"),
    "noSelectedDate": MessageLookupByLibrary.simpleMessage("No Selected Date"),
    "no_data": MessageLookupByLibrary.simpleMessage("No Data"),
    "offline": MessageLookupByLibrary.simpleMessage("Offline"),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "phone": MessageLookupByLibrary.simpleMessage("Phone Number"),
    "redError": MessageLookupByLibrary.simpleMessage("Red (Error)"),
    "registrationSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful",
    ),
    "resetPassword": MessageLookupByLibrary.simpleMessage("Reset Password"),
    "rtcError": MessageLookupByLibrary.simpleMessage("RTC Error"),
    "rtcErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Real-Time Clock synchronization issue.",
    ),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "selectDateAndTime": MessageLookupByLibrary.simpleMessage(
      "Select Date and Time",
    ),
    "selectRole": MessageLookupByLibrary.simpleMessage("Select Role"),
    "send": MessageLookupByLibrary.simpleMessage("Send"),
    "sensorError": MessageLookupByLibrary.simpleMessage("Sensor Error"),
    "sensorErrorMessageWithTemp": m1,
    "setNow": MessageLookupByLibrary.simpleMessage("Set Now"),
    "slave_clocks": MessageLookupByLibrary.simpleMessage("Slave Clocks"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "supervisor": MessageLookupByLibrary.simpleMessage("Supervisor"),
    "supports": MessageLookupByLibrary.simpleMessage("Supports"),
    "synchronized_clock": MessageLookupByLibrary.simpleMessage(
      "Synchronized Clock",
    ),
    "temperature": MessageLookupByLibrary.simpleMessage("Temperature"),
    "totalDevices": MessageLookupByLibrary.simpleMessage("Total Devices"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "user": MessageLookupByLibrary.simpleMessage("User"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "users": MessageLookupByLibrary.simpleMessage("Users"),
    "version": MessageLookupByLibrary.simpleMessage("Version"),
    "welcome": MessageLookupByLibrary.simpleMessage("Welcome"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
