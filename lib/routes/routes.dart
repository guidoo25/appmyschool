import 'package:appmyschool/screens/webview.dart';
import 'package:go_router/go_router.dart';




final appRouter = GoRouter(
  routes: [


    GoRoute(
      path: '/',
      builder: (context, state) => const WebViewScreen(),
    ),

   

  ]
  
);