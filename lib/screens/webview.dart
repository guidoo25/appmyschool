import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  Future<WebViewController>? _controllerFuture;
  late String loginUrl;
  final String homeUrl = 'https://www.myschool.cl/ams_home.php?usr=';
  bool _isLoading = true;
  int progress = 0;

  @override
  void initState() {
    super.initState();
    _controllerFuture = _initializeWebView();
  }

  Future<WebViewController> _initializeWebView() async {
    if (Platform.isAndroid) {
      // Inicializa WebView
      // WebView.platform = SurfaceAndroidWebView();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token') ?? 'default_token';
    final sessionId = prefs.getString('session_id') ?? '';
    
    loginUrl = 'https://www.myschool.cl/ams_indexApp.php?uuid=$sessionId&ID=$token';
    print('Login URL: $loginUrl');

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          setState(() {
            _isLoading = progress < 100;
          });
        },
        onPageFinished: (String url) async {
          if (url.contains("ams_home.php")) {
            await _saveSessionCookie();
          }
          setState(() {
            _isLoading = false;
          });
        },
      ));

    // Establece la cookie de sesión si existe
    if (sessionId.isNotEmpty) {
      await _setSessionCookie(sessionId);
      controller.loadRequest(Uri.parse('$homeUrl'));
    } else {
      controller.loadRequest(Uri.parse(loginUrl));
    }

    return controller;
  }

  Future<void> _setSessionCookie(String sessionId) async {
    WebViewCookie cookie = WebViewCookie(
      name: 'PHPSESSID',
      value: sessionId,
      domain: 'myschool.cl',
      path: '/',
   
    );
    await WebViewCookieManager().setCookie(cookie);
  }

  Future<void> _saveSessionCookie() async {
    final controller = await _controllerFuture;
    String cookies = await controller!.runJavaScriptReturningResult('document.cookie') as String;

    RegExp regExp = RegExp(r'PHPSESSID=([^;]+);?');
    Match? match = regExp.firstMatch(cookies);
    if (match != null) {
      String sessionId = match.group(1)!;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', sessionId);
      print("Cookie PHPSESSID guardada: $sessionId");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<WebViewController>(
          future: _controllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error al cargar el WebView'));
            } else {
              final controller = snapshot.data;
              return Stack(
                children: [
                  WebViewWidget(controller: controller!),
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.7),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('assets/logo.png'), // Asegúrate de reemplazar 'assets/logo.png' con la ruta de tu imagen
                            CircularProgressIndicator(color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Cerrar sesión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_back),
            label: 'Retroceder',
          ),
        ],
        onTap: (index) async {
          final controller = await _controllerFuture;
          if (index == 0) {
            controller!.loadRequest(Uri.parse(loginUrl));
          } else if (index == 1) {
            controller!.goBack();
          }
        },
      ),
    );
  }
}
