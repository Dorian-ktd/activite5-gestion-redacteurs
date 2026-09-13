import 'package:flutter/material.dart';

import 'views/redacteur_interface.dart';

void main() {
  // Initialiser les bindings Flutter (nécessaire pour path_provider)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Rédacteurs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const RedacteurInterface(),
      debugShowCheckedModeBanner: false,
    );
  }
}
