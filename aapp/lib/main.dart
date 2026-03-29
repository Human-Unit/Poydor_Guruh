import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DriverExamApp(),
    ),
  );
}

class DriverExamApp extends StatelessWidget {
  const DriverExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tajik Driver Exam MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 0, 0),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 0, 0, 0),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 10, 1, 31),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 35, 2, 48),
          elevation: 0,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}