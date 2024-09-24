// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class WebViewScreen extends StatefulWidget {
//   const WebViewScreen({Key? key}) : super(key: key);

//   @override
//   _WebViewScreenState createState() => _WebViewScreenState();
// }

// class _WebViewScreenState extends State<WebViewScreen> {
//   Future<WebViewController>? _controllerFuture;
//   late String loginUrl;
//   final String homeUrl = 'https://www.myschool.cl/ams_home.php?usr=';
//   bool _isLoading = true;
//   int progress = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controllerFuture = _initializeWebView();
//   }
// Future<void> _setAllCookies() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   final sessionId = prefs.getString('session_id') ?? '';
//   final otherCookieValue = prefs.getString('other_cookie') ?? '';

//   List<WebViewCookie> cookies = [
//     WebViewCookie(
//       name: 'PHPSESSID',
//       value: sessionId,
//       domain: 'myschool.cl',
//       path: '/',
//     ),
//     WebViewCookie(
//       name: 'OtherCookie',
//       value: otherCookieValue,
//       domain: 'myschool.cl',
//       path: '/',
//     ),
//     // Agrega aquí todas las cookies que necesites
//   ];

//   final cookieManager = WebViewCookieManager();
//   for (var cookie in cookies) {
//     await cookieManager.setCookie(cookie);
//   }
// }
//   Future<WebViewController> _initializeWebView() async {
//     if (Platform.isAndroid) {
//       // Inicializa WebView
//       // WebView.platform = SurfaceAndroidWebView();
//     }

//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('fcm_token') ?? 'default_token';
//     final sessionId = prefs.getString('session_id') ?? '';
    
//     loginUrl = 'https://www.myschool.cl/ams_indexApp.php?uuid=$sessionId&ID=$token';
//     print('Login URL: $loginUrl');

//     final controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(NavigationDelegate(
//         onProgress: (int progress) {
//           setState(() {
//             _isLoading = progress < 100;
//           });
//         },
//         onPageFinished: (String url) async {
//           if (url.contains("ams_home.php")) {
//             await _saveAllCookies();
//           }
//           setState(() {
//             _isLoading = false;
//           });
//         },
//       ));

//     // Establece la cookie de sesión si existe
//     if (sessionId.isNotEmpty) {
//   await _setAllCookies();
//       controller.loadRequest(Uri.parse('$homeUrl'));
//     } else {
//       controller.loadRequest(Uri.parse(loginUrl));
//     }

//     return controller;
//   }

//   Future<void> _setSessionCookie(String sessionId) async {
//     WebViewCookie cookie = WebViewCookie(
//       name: 'PHPSESSID',
//       value: sessionId,
//       domain: 'myschool.cl',
//       path: '/',
   
//     );
//     await WebViewCookieManager().setCookie(cookie);
//   }

//   Future<void> _saveAllCookies() async {
//     final controller = await _controllerFuture;
//     String cookiesString = await controller!.runJavaScriptReturningResult('document.cookie') as String;

//     List<String> cookiesList = cookiesString.split(';');
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     for (var cookie in cookiesList) {
//       List<String> cookieParts = cookie.split('=');
//       if (cookieParts.length >= 2) {
//         String name = cookieParts[0].trim();
//         String value = cookieParts[1].trim();
//         await prefs.setString(name, value);
//         print("Cookie $name guardada: $value");
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: FutureBuilder<WebViewController>(
//           future: _controllerFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Error al cargar el WebView'));
//             } else {
//               final controller = snapshot.data;
//               return Stack(
//                 children: [
//                   WebViewWidget(controller: controller!),
//                   if (_isLoading)
//                     Container(
//                       color: Colors.black.withOpacity(0.7),
//                       child: Center(
//                         child: CircularProgressIndicator(color: Colors.white),
//                       ),
//                     ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.logout),
//             label: 'Cerrar sesión',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.arrow_back),
//             label: 'Retroceder',
//           ),
//         ],
//         onTap: (index) async {
//           final controller = await _controllerFuture;
//           if (index == 0) {
//             controller!.loadRequest(Uri.parse(loginUrl));
//           } else if (index == 1) {
//             controller!.goBack();
//           }
//         },
//       ),
//     );
//   }
// }
