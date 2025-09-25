import 'package:flutter/material.dart';
import 'package:tasktracker/screens/splash.dart';
import 'package:tasktracker/task_color/app_color.dart';

void main() {
  runApp(const TaskTrackApp());
}

class TaskTrackApp extends StatelessWidget {
  const TaskTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TaskTrack",
      theme: ThemeData(
        primaryColor: AppColors.caramel,
        scaffoldBackgroundColor: AppColors.latte,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.caramel,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.saddle,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: AppColors.saddle),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.caramel,
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
