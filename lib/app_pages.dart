import 'package:get/get.dart';
import 'package:kaiten/app_routes.dart';
import 'package:kaiten/home/bindings/home_binding.dart';
import 'package:kaiten/home/views/home_screen.dart';
import 'package:kaiten/full_monitoring/screens/fullmonitoring_screen.dart';
import 'package:kaiten/full_monitoring/bindings/full_monitoring_binding.dart';
import 'package:kaiten/pose_estimation/bindings/pose_estimation_binding.dart';
import 'package:kaiten/pose_estimation/views/pose_estimation_view.dart';

class AppPages {
  static const initial = AppRoutes.home;

  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.poseEstimation,
      page: () => const PoseEstimationView(),
      binding: PoseEstimationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.fullMonitoring,
      page: () => const CameraScreen(),
      binding: FullMonitoringBinding(),
      transition: Transition.fade,
    ),
  ];
}
