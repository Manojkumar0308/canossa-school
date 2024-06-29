import 'package:canossa/login/view/login_screen.dart';
import 'package:flutter/material.dart';

import '../online_payment/view/failure.dart';
import '../online_payment/view/success.dart';

class RouteGenerator {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: ((context) => LoginScreen()));
      case '/success':
        return MaterialPageRoute(builder: (context) => const Success());
      case '/failure':
        return MaterialPageRoute(builder: (context) => const Failure());

      default:
        return MaterialPageRoute(
            builder: (context) => Scaffold(
                  body: Center(
                    child: Text("Not found ${settings.name}"),
                  ),
                ));
    }
  }
}
