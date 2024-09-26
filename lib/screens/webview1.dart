import 'package:appmyschool/providers/cubit/notifications_loaded_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // Asegúrate de tener esta dependencia en tu pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late InAppWebViewController _webViewController;
  late CookieManager _cookieManager;
  final String loginUrl = 'https://www.myschool.cl/ams_indexApp.php?uuid=1&ID=2&modo=exit';
  final String homeUrl = 'https://www.myschool.cl/ams_home.php?usr='; // Ajustar con la lógica del usuario
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cookieManager = CookieManager.instance();
    context.read<NotificationsCubit>().fetchToken(); // Solicitar token de notificación
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionId = prefs.getString('session_id');

    if (sessionId != null && sessionId.isNotEmpty) {
      await _cookieManager.setCookie(
        url: Uri.parse(loginUrl),
        name: "PHPSESSID",
        value: sessionId,
        domain: "www.myschool.cl",
        path: "/",
      );

      _webViewController.loadUrl(
        urlRequest: URLRequest(url: Uri.parse(homeUrl + '')), // Ajustar con el ID del usuario actual
      );
    }
  }

  Future<void> _saveSessionCookie() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Cookie> cookies = await _cookieManager.getCookies(url: Uri.parse("https://www.myschool.cl"));

    for (var cookie in cookies) {
      if (cookie.name == "PHPSESSID") {
        await prefs.setString('session_id', cookie.value);
        print("Cookie PHPSESSID guardada: ${cookie.value}");
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          builder: (context, state) {
            if (state is NotificationsLoaded) {
              return Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: Uri.parse(state.loginUrl)),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    onLoadStop: (controller, url) async {
                      if (url.toString().contains("ams_home.php")) {
                        await _saveSessionCookie();
                      }
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      print("Error de carga: $message");
                    },
                  ),
                  if (_isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.7),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/logoMS.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            const Text(
                              'Cargando...',
                              style: TextStyle(fontSize: 18, color: Colors.white),

                            ),
                          ],
                        ),
                      ),
                    )
                ],
              );
            } else if (state is NotificationsError) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text('No se pudo obtener la URL'));
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
        onTap: (index) {
          if (index == 0) {
            _webViewController.loadUrl(urlRequest: URLRequest(url: Uri.parse(loginUrl)));
          } else if (index == 1) {
            _webViewController.goBack();
          }
        },
      ),
    );
  }
}
