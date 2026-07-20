class LivenessChallenge {
  const LivenessChallenge({
    required this.challengeId,
    required this.actions,
    required this.expiresAt,
  });

  final String challengeId;
  final List<String> actions;
  final String expiresAt;

  factory LivenessChallenge.fromJson(Map<String, dynamic> json) {
    return LivenessChallenge(
      challengeId: json['challenge_id']?.toString() ?? '',
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      expiresAt: json['expires_at']?.toString() ?? '',
    );
  }
}

class VerificationStatus {
  const VerificationStatus({
    required this.canGoOnline,
    required this.selfieRequired,
    required this.hasActiveShift,
    required this.message,
    this.pendingVerificationId,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  final bool canGoOnline;
  final bool selfieRequired;
  final bool hasActiveShift;
  final String message;
  final String? pendingVerificationId;
  final int failedAttempts;
  final String? lockedUntil;

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      canGoOnline: json['can_go_online'] == true,
      selfieRequired: json['selfie_required'] == true,
      hasActiveShift: json['has_active_shift'] == true,
      message: json['message']?.toString() ?? '',
      pendingVerificationId: json['pending_verification_id']?.toString(),
      failedAttempts: (json['failed_attempts'] as num?)?.toInt() ?? 0,
      lockedUntil: json['locked_until']?.toString(),
    );
  }
}

class SelfieVerifyResult {
  const SelfieVerifyResult({
    required this.verified,
    required this.matched,
    required this.livenessPassed,
    required this.message,
    this.confidenceScore,
    this.verificationId,
    this.errorCode,
    this.steps = const {},
  });

  final bool verified;
  final bool matched;
  final bool livenessPassed;
  final String message;
  final double? confidenceScore;
  final String? verificationId;
  final String? errorCode;
  final Map<String, bool> steps;

  factory SelfieVerifyResult.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final steps = <String, bool>{};
    if (rawSteps is Map) {
      rawSteps.forEach((key, value) {
        steps[key.toString()] = value == true;
      });
    }
    return SelfieVerifyResult(
      verified: json['verified'] == true,
      matched: json['matched'] == true,
      livenessPassed: json['liveness_passed'] == true,
      message: json['message']?.toString() ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      verificationId: json['verification_id']?.toString(),
      errorCode: json['error_code']?.toString(),
      steps: steps,
    );
  }
}
