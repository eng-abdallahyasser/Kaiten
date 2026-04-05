import 'package:flutter/material.dart';
import 'package:kaiten/pose_estimation/widgets/pageboard.dart';
class ImageUploadingview extends StatelessWidget {
  const ImageUploadingview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Pageboard(),
        ],
      ),
    );
  }
}

