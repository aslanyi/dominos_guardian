import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocaLNotificationsHelper {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final _androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'com.example.dominos_guardian',
      'Dominos Guardian',
      'Dominos guardian notification',
      importance: Importance.Max,
      priority: Priority.High,
      ticker: 'ticker');
  final _iosPlatformChannelSpecifics = const IOSNotificationDetails();

  LocaLNotificationsHelper() {
    _initializeLocalNotification();
  }

  Future sendNotification(String message) async {
    var platformChannelSpecifics = NotificationDetails(
        _androidPlatformChannelSpecifics, _iosPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'Nöbetçi', message, platformChannelSpecifics);
  }

  Future sendScheduledNotification(String message, Time time) async {
    var scheduledNotificationDateTime = time;
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        _androidPlatformChannelSpecifics, _iosPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Nöbetçi',
        message, scheduledNotificationDateTime, platformChannelSpecifics);
  }

  Future<void> _initializeLocalNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
