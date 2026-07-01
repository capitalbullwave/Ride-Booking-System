import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/camera_strings.dart';
import 'package:wavego_driver/core/utils/picked_image.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/services/camera_service.dart';
import 'package:wavego_driver/widgets/camera/camera_error_panel.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

class CameraCaptureScreen extends ConsumerStatefulWidget {
  const CameraCaptureScreen({
    super.key,
    required this.lens,
    required this.title,
    required this.hint,
  });

  final CameraLensPreference lens;
  final String title;
  final String hint;

  @override
  ConsumerState<CameraCaptureScreen> createState() =>
      _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends ConsumerState<CameraCaptureScreen> {
  CameraFailureReason? _failure;
  String? _previewPath;
  bool _isInitializing = true;
  bool _isCapturing = false;
  late final CameraService _cameraService;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService(ref.read(permissionServiceProvider));
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _failure = null;
      _previewPath = null;
    });

    final result = await _cameraService.initialize(lens: widget.lens);

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _failure = result.failureReason ?? CameraFailureReason.unknown;
        _isInitializing = false;
      });
      return;
    }

    setState(() => _isInitializing = false);
  }

  Future<void> _capture() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final result = await _cameraService.capturePhoto();
      if (!mounted) return;
      setState(() {
        _previewPath = result.path;
        _isCapturing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failure = CameraFailureReason.captureFailed;
        _isCapturing = false;
      });
    }
  }

  Future<void> _usePhoto() async {
    final path = _previewPath;
    if (path == null) return;
    if (!mounted) return;
    Navigator.of(context).pop(path);
  }

  Future<void> _retake() async {
    setState(() => _previewPath = null);
    await _initializeCamera();
  }

  Future<void> _openSettings() async {
    await ref.read(permissionServiceProvider).openSettings();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const CameraLoadingPanel();
    }

    if (_failure != null) {
      return CameraErrorPanel(
        reason: _failure!,
        onRetry: _initializeCamera,
        onClose: () => Navigator.of(context).pop(),
        onOpenSettings: _openSettings,
      );
    }

    if (_previewPath != null) {
      return _buildCapturedPreview();
    }

    return _buildLivePreview();
  }

  Widget _buildLivePreview() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return CameraErrorPanel(
        reason: CameraFailureReason.initializationFailed,
        onRetry: _initializeCamera,
        onClose: () => Navigator.of(context).pop(),
        onOpenSettings: _openSettings,
      );
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            children: [
              Text(
                widget.hint,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: _isCapturing
                    ? CameraStrings.capturing
                    : CameraStrings.capturePhoto,
                icon: Icons.camera_alt,
                isLoading: _isCapturing,
                onPressed: _isCapturing ? null : _capture,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedPreview() {
    final path = _previewPath!;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: pickedImage(path, fit: BoxFit.contain),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: CameraStrings.retake,
                  variant: AppButtonVariant.outline,
                  onPressed: _retake,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: CameraStrings.usePhoto,
                  onPressed: _usePhoto,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
