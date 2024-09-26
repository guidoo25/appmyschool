import 'package:appmyschool/providers/bloc/notifiactions_bloc.dart';
import 'package:appmyschool/providers/cubit/notifications_loaded_cubit.dart';
import 'package:appmyschool/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart'; // Asegúrate de tener firebase_options.dart generado

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registra el handler de mensajes en segundo plano
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Solicitar permisos para notificaciones push en iOS
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permisos de notificación concedidos');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('Permisos de notificación provisionales concedidos');
  } else {
    print('Permisos de notificación denegados');
  }

  // Obtener el token de FCM
  final token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');

  final prefs = await SharedPreferences.getInstance();
  if (token != null) {
    await prefs.setString('fcm_token', token);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Asegúrate de inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Usa las opciones generadas para tu plataforma
  );

  await _initializeApp(); // Llama a la función que inicializa todo

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotificationsCubit()),
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
      theme: ThemeData(
        primarySwatch: Colors.blue, // Cambia el color principal a azul
      ),

      routerConfig: appRouter, // Usa el enrutador GoRouter que has definido
      debugShowCheckedModeBanner: false,
    );
  }
}
