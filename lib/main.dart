import 'package:appmyschool/providers/bloc/notifiactions_bloc.dart';
import 'package:appmyschool/providers/notificaciones.dart';
import 'package:appmyschool/routes/routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationsBloc.initializeFCM();

  final prefs = await SharedPreferences.getInstance();

  // Recuperar el token de FCM
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');

  if (token != null) {
    await prefs.setString('fcm_token', token);
  }


}

void main() async {
  await _initializeApp();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotificationsBloc())
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => HandleNotificationInteractions(child: child!),
    );
  }
}

class HandleNotificationInteractions extends StatefulWidget {
  final Widget child;
  const HandleNotificationInteractions({super.key, required this.child});

  @override
  State<HandleNotificationInteractions> createState() => _HandleNotificationInteractionsState();
}

class _HandleNotificationInteractionsState extends State<HandleNotificationInteractions> {
  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    context.read<NotificationsBloc>().handleRemoteMessage(message);

    final messageId = message.messageId?.replaceAll(':', '').replaceAll('%', '');
    appRouter.push('/');
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
