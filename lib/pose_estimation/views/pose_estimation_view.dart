import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pose_estimation_controller.dart';
import '../widgets/pageboard.dart';
import '../widgets/pose_painter.dart';

/// The main view for the Pose Estimation feature.
/// It displays the live camera feed and overlays a skeleton (pose skeleton) in real-time.
class PoseEstimationView extends GetView<PoseEstimationController> {
  const PoseEstimationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen Camera Preview
          Obx(() {
            final controllerVal = controller.cameraController.value;
            // Show a progress indicator while the camera is starting up
            if (controller.isInitializing.value || controllerVal == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Display the live camera feed
            return AspectRatio(
                aspectRatio: controllerVal.value.aspectRatio,
                child: CameraPreview(controllerVal),
            );
          }),

          // 2. Real-time Skeleton Overlay (drawn by PosePainter)
          Obx(() {
            final controllerVal = controller.cameraController.value;
            if (controllerVal == null || 
                !controllerVal.value.isInitialized || 
                controller.poses.isEmpty ||
                controller.absoluteImageSize == null ||
                controller.rotation == null) {
              return const SizedBox.shrink();
            }

            // The CustomPaint widget uses our PosePainter class to draw landmarks
            return CustomPaint(
              painter: PosePainter(
                controller.poses,
                controller.absoluteImageSize!,
                controller.rotation!,
              ),
            );
          }),

          // 3. UI Decoration (consistent with the rest of the app)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: const Pageboard(),
          ),

          // 4. Instructional Text
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(127),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Place yourself within the camera's view",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
