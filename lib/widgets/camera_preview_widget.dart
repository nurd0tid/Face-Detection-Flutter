import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController cameraController;

  const CameraPreviewWidget({Key? key, required this.cameraController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cameraController.value.isInitialized
        ? AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
