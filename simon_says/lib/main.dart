import 'package:flutter/material.dart';

import 'screens/main_menu_s.dart';

void main() {
  runApp(const SimonSaysApp());
}

class SimonSaysApp extends StatelessWidget {
  const SimonSaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simon Says',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
