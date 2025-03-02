import 'package:app_settings/app_settings.dart';
import 'package:ctue_app/core/constants/constants.dart';
import 'package:ctue_app/core/services/secure_storage_service.dart';
import 'package:ctue_app/core/services/shared_pref_service.dart';
import 'package:ctue_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:ctue_app/features/home/presentation/providers/home_provider.dart';
import 'package:ctue_app/features/learn/presentation/providers/learn_provider.dart';
import 'package:ctue_app/features/speech/presentation/pages/voice_setting_page.dart';
import 'package:ctue_app/features/skeleton/providers/selected_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: unused_import
import 'package:timezone/data/latest_all.dart' as tz; // For timezone support
import 'package:timezone/timezone.dart' as tz;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    final List<Setting> _settings = [
      Setting(
          icon: Icons.person,
          title: 'Cập nhật thông tin',
          onTap: () {
            Navigator.pushNamed(context, RouteNames.userInfo);
            Provider.of<HomeProvider>(context, listen: false)
                .saveRecentPage(RouteNames.userInfo);
          }),
      // Setting(icon: Icons.vpn_key, title: 'Đổi mật khẩu', onTap: () {}),
      Setting(
          icon: Icons.notifications_rounded,
          title: 'Thông báo',
          onTap: () async {
            if (!await Permission.notification.isGranted) {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            } else {
              // Show an informative message or snackbar prompting the user
              // to re-enable notifications from settings.
            }
          }),
      Setting(
          icon: Icons.headphones,
          title: 'Giọng đọc',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VoiceSettingPage(),
              ),
            );
          }),
      // Setting(icon: Icons.timer, title: 'Nhắc nhở', onTap: () {}),
    ];

    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          title: Text(
            'Cài đặt',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.navigate_before,
                size: 32,
              )),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 190,
              child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 10,
                    );
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      tileColor: Colors.white,
                      leading: Icon(_settings[index].icon),
                      title: Text(_settings[index].title),
                      onTap: _settings[index].onTap,
                    );
                  },
                  itemCount: _settings.length),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
                // height: 120,
                child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ListTile(
                  tileColor: Colors.white,
                  leading: const Icon(Icons.timer),
                  title: const Text('Nhắc nhở'),
                  trailing: Switch(
                    // This bool value toggles the switch.
                    value: Provider.of<LearnProvider>(context, listen: true)
                        .isRemind,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      if (value == false) {
                        flutterLocalNotificationsPlugin.cancel(0);
                      } else {
                        final now = DateTime.now();
                        final scheduledTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            Provider.of<LearnProvider>(context, listen: false)
                                .remindTime
                                .hour,
                            Provider.of<LearnProvider>(context, listen: false)
                                .remindTime
                                .minute);
                        scheduleNotification(
                            'Nhắc nhở',
                            'Hãy nghỉ ngơi một chút và bắt đầu học cùng CTUE nào!',
                            scheduledTime);
                      }
                      // This is called when the user toggles the switch.
                      Provider.of<LearnProvider>(context, listen: false)
                          .isRemind = value;
                    },
                  ),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12))),
                ),
                ListTile(
                  tileColor: Colors.white,
                  leading: null,
                  title: Text(
                    'Đặt giờ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${Provider.of<LearnProvider>(context, listen: true).remindTime.hour}:${Provider.of<LearnProvider>(context, listen: true).remindTime.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                        size: 30,
                      )
                    ],
                  ),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12))),
                  onTap: () async {
                    // const AndroidNotificationDetails
                    //     androidNotificationDetails = AndroidNotificationDetails(
                    //         'your channel id', 'your channel name',
                    //         channelDescription: 'your channel description',
                    //         importance: Importance.max,
                    //         priority: Priority.high,
                    //         icon: 'ctue_icon',
                    //         ticker: 'ticker');
                    // const NotificationDetails notificationDetails =
                    //     NotificationDetails(
                    //         android: androidNotificationDetails);
                    // await flutterLocalNotificationsPlugin.show(
                    //     1,
                    //     'Hey Thanh Liem',
                    //     'Bạn có 3 từ cần ôn tập!',
                    //     notificationDetails,
                    //     payload: 'item x');
                    TimeOfDay? selectedTime24Hour = await showTimePicker(
                      context: context,
                      initialTime:
                          Provider.of<LearnProvider>(context, listen: false)
                              .remindTime,
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light(),
                          child: MediaQuery(
                            data: MediaQuery.of(context)
                                .copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (selectedTime24Hour != null) {
                      // ignore: use_build_context_synchronously
                      Provider.of<LearnProvider>(context, listen: false)
                          .remindTime = selectedTime24Hour;
                      if (Provider.of<LearnProvider>(context, listen: false)
                          .isRemind) {
                        final now = DateTime.now();
                        final scheduledTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            selectedTime24Hour.hour,
                            selectedTime24Hour.minute);
                        await flutterLocalNotificationsPlugin.cancel(0);
                        // Schedule the notification
                        await scheduleNotification(
                            'Nhắc nhở',
                            'Hãy nghỉ ngơi một chút và bắt đầu học cùng CTUE nào!',
                            scheduledTime);
                      }
                    }
                  },
                ),
              ],
            )),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Phiên bản ứng dụng 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    // height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                const MaterialStatePropertyAll(Colors.red),
                            shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)))),
                        onPressed: Provider.of<AuthProvider>(context,
                                    listen: true)
                                .isLoading
                            ? null
                            : () async {
                                try {
                                  await Provider.of<AuthProvider>(context,
                                          listen: false)
                                      .eitherFailureOrLogout();

                                  // ignore: use_build_context_synchronously
                                  if (Provider.of<AuthProvider>(context,
                                              listen: false)
                                          .statusCode ==
                                      200) {
                                    await flutterLocalNotificationsPlugin
                                        .cancelAll();

                                    // await SecureStorageService.secureStorage
                                    //     .delete(key: 'accessToken');

                                    await SecureStorageService.secureStorage
                                        .deleteAll();

                                    // Clear data in shared preferences
                                    await SharedPrefService.prefs.clear();

                                    // ignore: use_build_context_synchronously
                                    Provider.of<SelectedPageProvider>(context,
                                            listen: false)
                                        .selectedPage = 0;

                                    await Provider.of<HomeProvider>(context,
                                            listen: false)
                                        .removeRecentPages();

                                    FirebaseMessaging.instance
                                        .unsubscribeFromTopic('all');
                                    FirebaseMessaging.instance.deleteToken();

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushNamedAndRemoveUntil(
                                        context, '/welcome', (route) => false);
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              },
                        child: Text(
                          'Đăng xuất',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                        )),
                  )
                ],
              ),
            )
          ],
        ));
  }
}

class Setting {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  Setting({required this.icon, required this.title, required this.onTap});
}

tz.TZDateTime _nextInstanceOfReminder(DateTime scheduledTime) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

Future<void> scheduleNotification(
    String title, String body, DateTime scheduledTime) async {
  // Configure Android-specific details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    icon: 'ctue_icon',
  );

  // Configure iOS-specific details
  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

  // Configure common platform details
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  // Schedule the notification using timezone support
  await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      _nextInstanceOfReminder(scheduledTime), // Use the local timezone
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time);
}
