import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable selected index for the bottom navigation bar
  var selectedIndex = 0.obs;

  // Navigation Methods
  void goToPoseEstimation() {
    Get.toNamed('/pose_estimation');
  }

  void goToFullMonitoring() {
    Get.toNamed('/full_monitoring');
  }

  void goToFoodGuide() {
    selectedIndex.value = 2;
  }

  void onBottomNavItemTapped(int index) {
    selectedIndex.value = index;
  }
}
