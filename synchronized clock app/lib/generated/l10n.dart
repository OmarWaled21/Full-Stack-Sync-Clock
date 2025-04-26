// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `en`
  String get languageCode {
    return Intl.message('en', name: 'languageCode', desc: '', args: []);
  }

  /// `Master Clock`
  String get master_clock {
    return Intl.message(
      'Master Clock',
      name: 'master_clock',
      desc: '',
      args: [],
    );
  }

  /// `Slave Clocks`
  String get slave_clocks {
    return Intl.message(
      'Slave Clocks',
      name: 'slave_clocks',
      desc: '',
      args: [],
    );
  }

  /// `Synchronized Clock`
  String get synchronized_clock {
    return Intl.message(
      'Synchronized Clock',
      name: 'synchronized_clock',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Device Overview`
  String get deviceOverview {
    return Intl.message(
      'Device Overview',
      name: 'deviceOverview',
      desc: '',
      args: [],
    );
  }

  /// `Total Devices`
  String get totalDevices {
    return Intl.message(
      'Total Devices',
      name: 'totalDevices',
      desc: '',
      args: [],
    );
  }

  /// `Green (OK)`
  String get greenOk {
    return Intl.message('Green (OK)', name: 'greenOk', desc: '', args: []);
  }

  /// `Red (Error)`
  String get redError {
    return Intl.message('Red (Error)', name: 'redError', desc: '', args: []);
  }

  /// `Gray (Disconnected)`
  String get grayDisconnected {
    return Intl.message(
      'Gray (Disconnected)',
      name: 'grayDisconnected',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message('Welcome', name: 'welcome', desc: '', args: []);
  }

  /// `Users`
  String get users {
    return Intl.message('Users', name: 'users', desc: '', args: []);
  }

  /// `Supervisor`
  String get supervisor {
    return Intl.message('Supervisor', name: 'supervisor', desc: '', args: []);
  }

  /// `Add Device`
  String get addDevice {
    return Intl.message('Add Device', name: 'addDevice', desc: '', args: []);
  }

  /// `Logs`
  String get logs {
    return Intl.message('Logs', name: 'logs', desc: '', args: []);
  }

  /// `Edit Time`
  String get edit_time {
    return Intl.message('Edit Time', name: 'edit_time', desc: '', args: []);
  }

  /// `Supports`
  String get supports {
    return Intl.message('Supports', name: 'supports', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `No Data`
  String get no_data {
    return Intl.message('No Data', name: 'no_data', desc: '', args: []);
  }

  /// `Add User`
  String get add_user {
    return Intl.message('Add User', name: 'add_user', desc: '', args: []);
  }

  /// `Add Account`
  String get addAccount {
    return Intl.message('Add Account', name: 'addAccount', desc: '', args: []);
  }

  /// `First Name`
  String get firstName {
    return Intl.message('First Name', name: 'firstName', desc: '', args: []);
  }

  /// `Last Name`
  String get lastName {
    return Intl.message('Last Name', name: 'lastName', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Select Role`
  String get selectRole {
    return Intl.message('Select Role', name: 'selectRole', desc: '', args: []);
  }

  /// `User`
  String get user {
    return Intl.message('User', name: 'user', desc: '', args: []);
  }

  /// `Registration successful`
  String get registrationSuccess {
    return Intl.message(
      'Registration successful',
      name: 'registrationSuccess',
      desc: '',
      args: [],
    );
  }

  /// `No logs available.`
  String get NoLogsAvailable {
    return Intl.message(
      'No logs available.',
      name: 'NoLogsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `RTC Error`
  String get rtcError {
    return Intl.message('RTC Error', name: 'rtcError', desc: '', args: []);
  }

  /// `Low Battery`
  String get lowBattery {
    return Intl.message('Low Battery', name: 'lowBattery', desc: '', args: []);
  }

  /// `Sensor Error`
  String get sensorError {
    return Intl.message(
      'Sensor Error',
      name: 'sensorError',
      desc: '',
      args: [],
    );
  }

  /// `Temperature sensor malfunction. Current temperature: {temp}°C`
  String sensorErrorMessageWithTemp(Object temp) {
    return Intl.message(
      'Temperature sensor malfunction. Current temperature: $temp°C',
      name: 'sensorErrorMessageWithTemp',
      desc: '',
      args: [temp],
    );
  }

  /// `Real-Time Clock synchronization issue.`
  String get rtcErrorMessage {
    return Intl.message(
      'Real-Time Clock synchronization issue.',
      name: 'rtcErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Battery level is low. {bat}%`
  String lowBatteryMessage(Object bat) {
    return Intl.message(
      'Battery level is low. $bat%',
      name: 'lowBatteryMessage',
      desc: '',
      args: [bat],
    );
  }

  /// `Edit Master Clock`
  String get editMasterClock {
    return Intl.message(
      'Edit Master Clock',
      name: 'editMasterClock',
      desc: '',
      args: [],
    );
  }

  /// `Select Date and Time`
  String get selectDateAndTime {
    return Intl.message(
      'Select Date and Time',
      name: 'selectDateAndTime',
      desc: '',
      args: [],
    );
  }

  /// `No Selected Date`
  String get noSelectedDate {
    return Intl.message(
      'No Selected Date',
      name: 'noSelectedDate',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Enter`
  String get enter {
    return Intl.message('Enter', name: 'enter', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Set Now`
  String get setNow {
    return Intl.message('Set Now', name: 'setNow', desc: '', args: []);
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Clock Status`
  String get clockStatus {
    return Intl.message(
      'Clock Status',
      name: 'clockStatus',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Good`
  String get good {
    return Intl.message('Good', name: 'good', desc: '', args: []);
  }

  /// `Offline`
  String get offline {
    return Intl.message('Offline', name: 'offline', desc: '', args: []);
  }

  /// `Temperature`
  String get temperature {
    return Intl.message('Temperature', name: 'temperature', desc: '', args: []);
  }

  /// `Battery Level`
  String get batteryLevel {
    return Intl.message(
      'Battery Level',
      name: 'batteryLevel',
      desc: '',
      args: [],
    );
  }

  /// `Last Update`
  String get lastUpdate {
    return Intl.message('Last Update', name: 'lastUpdate', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Reset Password`
  String get resetPassword {
    return Intl.message(
      'Reset Password',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password?',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Login successful. Welcome back!`
  String get loginSuccessful {
    return Intl.message(
      'Login successful. Welcome back!',
      name: 'loginSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Clock Name`
  String get clockName {
    return Intl.message('Clock Name', name: 'clockName', desc: '', args: []);
  }

  /// `Max`
  String get max {
    return Intl.message('Max', name: 'max', desc: '', args: []);
  }

  /// `Min`
  String get min {
    return Intl.message('Min', name: 'min', desc: '', args: []);
  }

  /// `Add New Device`
  String get addNewDevice {
    return Intl.message(
      'Add New Device',
      name: 'addNewDevice',
      desc: '',
      args: [],
    );
  }

  /// `No devices found`
  String get noDevicesFound {
    return Intl.message(
      'No devices found',
      name: 'noDevicesFound',
      desc: '',
      args: [],
    );
  }

  /// `Enter Wifi Credentials`
  String get enterWifiCredentials {
    return Intl.message(
      'Enter Wifi Credentials',
      name: 'enterWifiCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Delete Clock`
  String get deleteClock {
    return Intl.message(
      'Delete Clock',
      name: 'deleteClock',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure deleting this clock?`
  String get confirmDeleteClock {
    return Intl.message(
      'Are you sure deleting this clock?',
      name: 'confirmDeleteClock',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
