import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Helpers/pose _contour_overlay.dart';
import '../controllers/full_monitoring_controller.dart';

class CameraScreen extends GetView<FullMonitoringController> {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isInitializing.value ||
          controller.cameraController.value == null ||
          !controller.cameraController.value!.value.isInitialized) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing Camera...'),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: const Text('Real-Time Posture Monitoring'),
          backgroundColor: Colors.deepPurple,
          elevation: 4,
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Camera Preview
                  LayoutBuilder(
                    builder: (context, constraints) {
                      controller.displayWidth = constraints.maxWidth;
                      controller.displayHeight = constraints.maxHeight;
                      controller.updateCameraLayout();
                      return CameraPreview(controller.cameraController.value!);
                    },
                  ),

                  // Pose & Contour Overlay
                  Positioned(
                    left: controller.offsetX,
                    top: controller.offsetY,
                    width: controller.actualCameraWidth,
                    height: controller.actualCameraHeight,
                    child: Obx(() => PoseContourOverlay(
                      poses: controller.poses,
                      contour: controller.contour,
                      corners: controller.corners,
                      cameraController: controller.cameraController.value!,
                      sensorOrientation: controller.sensorOrientation,
                      displayWidth: controller.actualCameraWidth,
                      displayHeight: controller.actualCameraHeight,
                      yAdjustment: controller.yAdjustment,
                      cameraImageWidth: controller.cameraImageWidth,
                      cameraImageHeight: controller.cameraImageHeight,
                    )),
                  ),

                  // Warning Banner
                  Positioned(
                    top: 50,
                    left: 20,
                    right: 20,
                    child: ValueListenableBuilder<String>(
                      valueListenable: controller.warningText,
                      builder: (context, warning, child) {
                        if (warning.isEmpty) return const SizedBox.shrink();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  warning,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Info Box
                  Positioned(
                    bottom: 50,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '👤 Poses: ${controller.poses.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📍 Contours: ${controller.contour.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '🔊 Alarm: ${controller.isAlarmPlaying.value ? "Playing" : "Silent"}',
                            style: TextStyle(
                              color: controller.isAlarmPlaying.value ? Colors.red : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '📹 Stream: ${controller.isStreamActive.value ? "Active" : "Stopped"}',
                            style: TextStyle(
                              color: controller.isStreamActive.value ? Colors.green : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Obx(() => FloatingActionButton.extended(
          onPressed: controller.startRecordingAndSend,
          icon: Icon(controller.isRecording.value ? Icons.stop : Icons.camera_alt),
          label: Text(controller.isRecording.value ? 'Processing...' : 'Detect Area'),
          backgroundColor: controller.isRecording.value ? Colors.red : Colors.deepPurple,
        )),
      );
    });
  }
}