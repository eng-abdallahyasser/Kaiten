import 'package:get/get.dart';

class HomeController extends GetxController {
  // Navigation Methods
  void goToPoseEstimation() {
    Get.toNamed('/pose_estimation');
  }

  void goToFullMonitoring() {
    Get.toNamed('/full_monitoring');
  }

  void goToFoodGuide() {
    // Placeholder for now
    Get.snackbar(
      "Coming Soon", 
      "The Food Guide feature is currently under development.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void onBottomNavItemTapped(int index) {
    // Handle bottom navigation if needed in the future
    print("Bottom nav item $index tapped");
  }
}
