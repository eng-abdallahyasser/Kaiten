import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseEstimationController extends GetxController {
  // --- Observables ---
  final Rx<CameraController?> cameraController = Rx<CameraController?>(null);
  final RxBool isInitializing = true.obs;
  final RxList<Pose> poses = <Pose>[].obs;
  
  // --- ML Kit Components ---
  late PoseDetector _poseDetector;
  bool _isBusy = false;

  // --- Image Metadata (for coordinate translation) ---
  Size? absoluteImageSize;
  InputImageRotation? rotation;

  @override
  void onInit() {
    super.onInit();
    _initializePoseDetector();
    _initializeCamera();
  }

  /// Initialize the Google ML Kit Pose Detector with the "accurate" model.
  void _initializePoseDetector() {
    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        mode: PoseDetectionMode.stream,
        model: PoseDetectionModel.accurate,
      ),
    );
  }

  /// Locate the back camera and initialize the controller.
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      // Select the back-facing camera
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        // YUV420 format is required for ML Kit image stream
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      cameraController.value = controller;
      
      // Start processing frames from the camera
      _startImageStream();
      isInitializing.value = false;
    } catch (e) {
      debugPrint("❌ Camera initialization error: $e");
    }
  }

  /// Register the listener for each camera frame.
  void _startImageStream() {
    final controller = cameraController.value;
    if (controller != null && controller.value.isInitialized) {
      controller.startImageStream((CameraImage image) async {
        if (_isBusy) return;
        _isBusy = true;

        try {
          // Convert the raw camera frame to a format ML Kit understands
          final inputImage = _processCameraImage(image);
          if (inputImage == null) return;

          // Run the pose detection model
          final detectedPoses = await _poseDetector.processImage(inputImage);
          
          // Store metadata for the painter
          absoluteImageSize = inputImage.metadata?.size;
          rotation = inputImage.metadata?.rotation;
          
          // Update the observable list
          poses.assignAll(detectedPoses);
        } catch (e) {
          debugPrint("⚠️ Pose detection error: $e");
        } finally {
          _isBusy = false;
        }
      });
    }
  }

  /// Converts a [CameraImage] from the camera stream to an [InputImage] for ML Kit.
  InputImage? _processCameraImage(CameraImage image) {
    try {
      final controller = cameraController.value;
      if (controller == null) return null;

      final camera = controller.description;
      final sensorOrientation = camera.sensorOrientation;
      
      // Handle the physical orientation of the device sensor
      final inputImageRotation = InputImageRotationValue.fromRawValue(sensorOrientation) 
          ?? InputImageRotation.rotation90deg;

      final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) 
          ?? (Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888);

      final plane = image.planes.first;

      // Extract bytes from the image planes
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: inputImageRotation,
          format: inputImageFormat,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint("❌ Error processing camera image: $e");
      return null;
    }
  }

  @override
  void onClose() {
    // Properly clean up resources to prevent memory leaks
    cameraController.value?.dispose();
    _poseDetector.close();
    super.onClose();
  }
}
