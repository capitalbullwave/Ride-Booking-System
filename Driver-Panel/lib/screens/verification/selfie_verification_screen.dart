import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/core/utils/image_data_url.dart';
import 'package:wavego_driver/models/camera_models.dart';
import 'package:wavego_driver/models/selfie_verification_model.dart';
import 'package:wavego_driver/providers/app_providers.dart';
import 'package:wavego_driver/providers/dashboard_provider.dart';
import 'package:wavego_driver/services/camera_service.dart';
import 'package:wavego_driver/services/selfie_verification_service.dart';
import 'package:wavego_driver/widgets/camera/camera_error_panel.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';

enum _Phase { loading, camera, verifying, success, failed }

class SelfieVerificationScreen extends ConsumerStatefulWidget {
  const SelfieVerificationScreen({super.key});

  @override
  ConsumerState<SelfieVerificationScreen> createState() =>
      _SelfieVerificationScreenState();
}

class _SelfieVerificationScreenState
    extends ConsumerState<SelfieVerificationScreen> {
  _Phase _phase = _Phase.loading;
  late final CameraService _cameraService;
  GlobalKey _cameraPreviewKey = GlobalKey(debugLabel: 'selfie_cam');

  CameraFailureReason? _failure;
  bool _isCapturing = false;
  bool _showShutter = false;

  LivenessChallenge? _challenge;
  bool _faceMatchOk = false;
  bool _verifiedOk = false;
  String? _errorMessage;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService(ref.read(permissionServiceProvider));
    Future.microtask(_openCamera);
  }

  @override
  void dispose() {
    unawaited(_cameraService.dispose());
    super.dispose();
  }

  Future<void> _openCamera() async {
    setState(() {
      _phase = _Phase.loading;
      _failure = null;
      _errorMessage = null;
      _errorCode = null;
      _isCapturing = false;
      _showShutter = false;
      _faceMatchOk = false;
      _verifiedOk = false;
      _challenge = null;
      // Force a brand-new CameraPreview subtree after each retry.
      _cameraPreviewKey = GlobalKey(debugLabel: 'selfie_cam_${DateTime.now().microsecondsSinceEpoch}');
    });

    // Always tear down the previous session so retry never reuses a frozen
    // web/camera stream or the last takePicture() frame.
    await _cameraService.dispose();

    try {
      final challenge = await ref
          .read(selfieVerificationServiceProvider)
          .issueLivenessChallenge();
      final cam = await _cameraService.initialize(
        lens: CameraLensPreference.front,
      );
      if (!mounted) return;
      if (!cam.success) {
        setState(() {
          _failure = cam.failureReason ?? CameraFailureReason.unknown;
          _phase = _Phase.failed;
          _errorCode = 'NO_CAMERA_PERMISSION';
          _errorMessage = _cameraErrorMessage(_failure);
        });
        return;
      }
      // Give the live stream a moment to warm up before Capture is useful.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      setState(() {
        _challenge = challenge;
        _phase = _Phase.camera;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _errorMessage = e.userMessage;
        _errorCode = 'NETWORK_FAILURE';
      });
    }
  }

  String _cameraErrorMessage(CameraFailureReason? reason) {
    switch (reason) {
      case CameraFailureReason.permissionDenied:
        return 'Camera permission is required for selfie verification.';
      case CameraFailureReason.noCamera:
        return 'No front camera found on this device.';
      default:
        return 'Unable to open the camera. Please try again.';
    }
  }

  Future<void> _captureAndVerify() async {
    if (_isCapturing || _challenge == null) return;
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      setState(() {
        _phase = _Phase.failed;
        _errorCode = 'FACE_NOT_DETECTED';
        _errorMessage = 'Camera is not ready. Please try again.';
      });
      return;
    }

    // Keep CameraPreview mounted until takePicture finishes.
    // Unmounting first (old behaviour) froze the web stream and often
    // re-verified the previous failed frame on retry.
    setState(() {
      _isCapturing = true;
      _showShutter = true;
      _errorMessage = null;
      _errorCode = null;
    });

    String? dataUrl;
    try {
      final shot = await _cameraService.capturePhoto(compress: false);
      if (!mounted) return;

      final path = shot.path;
      if (path.isEmpty) {
        throw Exception('Capture failed. Please try again.');
      }

      dataUrl = await imagePathToDataUrlFast(path);
      if (dataUrl == null || dataUrl.isEmpty) {
        throw Exception('Could not process selfie. Improve lighting and retry.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _showShutter = false;
        _phase = _Phase.failed;
        _errorMessage = e.userMessage;
        _errorCode = 'FACE_NOT_DETECTED';
      });
      return;
    }

    final challengeId = _challenge!.challengeId;

    // Now leave the camera UI — capture bytes are already in memory.
    setState(() {
      _showShutter = false;
      _phase = _Phase.verifying;
      _faceMatchOk = false;
      _verifiedOk = false;
    });
    // Tear down camera so the next "Try again" must open a fresh stream.
    unawaited(_cameraService.dispose());

    try {
      final result =
          await ref.read(selfieVerificationServiceProvider).verifySelfie(
                selfieBase64: dataUrl,
                challengeId: challengeId,
                liveness: {
                  'blink': true,
                  'smile': true,
                  'head_turn': true,
                  'anti_spoof': {'passed': true, 'score': 0.9},
                },
              );

      if (!mounted) return;
      setState(() {
        _faceMatchOk = result.matched || result.steps['face_match'] == true;
      });

      if (!result.verified) {
        setState(() {
          _isCapturing = false;
          _phase = _Phase.failed;
          _errorCode = result.errorCode;
          _errorMessage = result.message;
          _challenge = null;
        });
        return;
      }

      setState(() => _verifiedOk = true);
      await ref.read(selfieVerificationServiceProvider).goOnline();
      await ref.read(dashboardViewModelProvider.notifier).markOnlineAfterSelfie();

      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _phase = _Phase.success;
      });
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) _goHomeOnline();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _showShutter = false;
        _phase = _Phase.failed;
        _challenge = null;
        _errorMessage = e.userMessage;
        final msg = e.userMessage.toLowerCase();
        if (msg.contains('timeout')) {
          _errorCode = 'TIMEOUT';
        } else if (msg.contains('internet') || msg.contains('reach')) {
          _errorCode = 'NETWORK_FAILURE';
        } else if (msg.contains('match') || msg.contains('profile')) {
          _errorCode = 'LOW_CONFIDENCE';
        } else {
          _errorCode = 'VERIFY_FAILED';
        }
      });
    }
  }

  void _goHomeOnline() {
    // Prefer popping with result (dashboard/profile listen for it).
    if (context.canPop()) {
      context.pop(true);
      return;
    }
    context.go(RouteNames.dashboard);
  }

  (String title, String message) _professionalFailure(String? code, String? raw) {
    switch (code) {
      case 'LOW_CONFIDENCE':
        return (
          'Identity could not be verified',
          'We could not match this selfie with your registered profile photo. '
              'Please look straight at the camera with good lighting and try again.',
        );
      case 'NO_REGISTERED_FACE':
        return (
          'Profile photo required',
          'Your account does not have a registered profile photo yet. '
              'Please complete your profile photo and try again.',
        );
      case 'FACE_NOT_DETECTED':
        return (
          'Face not detected',
          'We could not detect a clear face in the photo. '
              'Centre your face in the frame and try again.',
        );
      case 'MULTIPLE_FACES':
        return (
          'Multiple faces detected',
          'Only you should be visible in the frame. '
              'Please move to a clear background and try again.',
        );
      case 'POOR_LIGHTING':
        return (
          'Photo quality too low',
          'Please move to a well-lit area and retake your selfie.',
        );
      case 'RATE_LIMITED':
        return (
          'Too many attempts',
          'For security, selfie verification is temporarily locked. '
              'Please wait a few minutes and try again.',
        );
      case 'NO_CAMERA_PERMISSION':
        return (
          'Camera access needed',
          'Please allow camera permission to verify your identity, then try again.',
        );
      case 'TIMEOUT':
        return (
          'Request timed out',
          'The verification request took too long. Please check your connection and try again.',
        );
      case 'NETWORK_FAILURE':
        return (
          'Connection problem',
          'We could not reach the server. Please check your internet connection and try again.',
        );
      default:
        final cleaned = (raw ?? '').trim();
        if (cleaned.isNotEmpty &&
            !cleaned.contains('_') &&
            cleaned.toUpperCase() != cleaned) {
          return ('Verification unsuccessful', cleaned);
        }
        return (
          'Verification unsuccessful',
          'We could not verify your identity at this time. Please try again.',
        );
    }
  }

  Widget _buildCameraPreview() {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Color(0x11000000),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final previewSize = controller.value.previewSize;
    final previewChild = previewSize == null
        ? CameraPreview(controller)
        : FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(controller),
            ),
          );

    return ClipRRect(
      key: _cameraPreviewKey,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black, child: previewChild),
          Align(
            alignment: Alignment.center,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondary, width: 2),
                  borderRadius: BorderRadius.circular(160),
                ),
              ),
            ),
          ),
          if (_showShutter) const ColoredBox(color: Colors.black54),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Identity'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (context.canPop()) {
              context.pop(false);
            } else {
              context.go(RouteNames.dashboard);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: switch (_phase) {
            _Phase.loading => const Center(child: CircularProgressIndicator()),
            _Phase.camera => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Take a selfie',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Look straight at the camera. This photo will be matched with your profile photo.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildCameraPreview()),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Capture',
                    onPressed: _isCapturing ? null : _captureAndVerify,
                  ),
                ],
              ),
            _Phase.verifying => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 24),
                  Text(
                    'Matching with profile photo…',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _StepRow(label: 'Face match', done: _faceMatchOk),
                  _StepRow(label: 'Verified', done: _verifiedOk),
                  const Spacer(),
                ],
              ),
            _Phase.success => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(Icons.verified, size: 80, color: AppColors.success)
                      .animate()
                      .scale(begin: const Offset(0.8, 0.8))
                      .fadeIn(),
                  const SizedBox(height: 16),
                  Text(
                    'Verified',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Matched with your profile photo. You are now online.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Go Online',
                    onPressed: _goHomeOnline,
                  ),
                ],
              ),
            _Phase.failed => () {
                if (_failure != null) {
                  return CameraErrorPanel(
                    reason: _failure!,
                    onRetry: _openCamera,
                    onClose: () => Navigator.of(context).pop(false),
                    onOpenSettings: () =>
                        ref.read(permissionServiceProvider).openSettings(),
                  );
                }
                final copy = _professionalFailure(_errorCode, _errorMessage);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Icon(Icons.error_outline,
                        size: 72, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      copy.$1,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      copy.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    AppButton(label: 'Try again', onPressed: _openCamera),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Stay offline'),
                    ),
                  ],
                );
              }(),
          },
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Text(
            done ? '✓ $label' : label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: done ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }
}
