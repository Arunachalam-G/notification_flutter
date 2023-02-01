// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool? hasPendingNotifications;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupPushNotification();
  runApp(const MyApp());
}

const channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
);

Future setupPushNotification() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  final ln = FlutterLocalNotificationsPlugin();
  var details = await ln.getNotificationAppLaunchDetails();
  if (details?.didNotificationLaunchApp ?? false) {
    final list = await ln.getActiveNotifications();
    hasPendingNotifications = list.isNotEmpty;
    final response = details?.notificationResponse;
    if (response?.payload != null) {
      await Future.delayed(const Duration(seconds: 1));
      final context = navigatorKey.currentContext;
      if (context != null) {
        if (response?.payload == '2') {
          Navigator.pushNamed(context, SecondScreen.routeName);
        } else if (response?.payload == '3') {
          Navigator.pushNamed(context, ThirdScreen.routeName);
        }
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey,
      routes: {
        '/': (context) => const MyHomePage(),
        SecondScreen.routeName: (context) => const SecondScreen(),
        ThirdScreen.routeName: (context) => const ThirdScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                showLocalNotification(
                  body: 'Go to screen 2',
                  page: '2',
                );
                showLocalNotification(
                  body: 'Go to screen 3',
                  page: '3',
                );
              },
              child: const Text(
                'Schedule Local Notifications',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  static const routeName = '/second';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Screen 2'),
      ),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  static const routeName = '/third';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Screen 3'),
      ),
    );
  }
}

Future<void> showLocalNotification({
  required String body,
  required String page,
  bool show = true,
}) async {
  const initializationSettingsAndroid =
      AndroidInitializationSettings('launch_image');

  const initializationSettingsIOS = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  final localNotification = FlutterLocalNotificationsPlugin();

  await localNotification.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onSelect,
    onDidReceiveBackgroundNotificationResponse: onSelect2,
  );
  localNotification.schedule(
    DateTime.now().microsecond,
    'Notification Flutter',
    body,
    DateTime.now().add(
      const Duration(seconds: 3),
    ),
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: 'launch_image',
      ),
    ),
    payload: page,
  );
  return;
}

onSelect(NotificationResponse response) async {
  debugPrint('😃 onDidReceiveNotificationResponse');
  final context = navigatorKey.currentContext;
  if (response.payload != null && context != null) {
    if (response.payload == '2') {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamed(context, SecondScreen.routeName);
    } else if (response.payload == '3') {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamed(context, ThirdScreen.routeName);
    }
  }
}

@pragma('vm:entry-point')
onSelect2(NotificationResponse response) async {
  debugPrint('😃 onDidReceiveBackgroundNotificationResponse');
  final context = navigatorKey.currentContext;
  if (response.payload != null && context != null) {
    if (response.payload == '2') {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamed(context, SecondScreen.routeName);
    } else if (response.payload == '3') {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushNamed(context, ThirdScreen.routeName);
    }
  }
}
