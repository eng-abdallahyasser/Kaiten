import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaiten/home/views/home_screen.dart';
import 'package:kaiten/full_monitoring/screens/fullmonitoring_screen.dart';
import 'package:kaiten/full_monitoring/bindings/full_monitoring_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaiten',
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/full_monitoring',
          page: () => const CameraScreen(),
          binding: FullMonitoringBinding(),
        ),
      ],
    );
  }
}
