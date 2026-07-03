/// Account menu verification state from backend registration progress.
class AccountVerificationMap {
  const AccountVerificationMap(this._verifiedById);

  final Map<String, bool> _verifiedById;

  bool isVerified(String id) => _verifiedById[id] ?? false;

  static AccountVerificationMap fromProgress(Map<String, dynamic> progress) {
    final map = <String, bool>{};
    final items = progress['account_items'] as List<dynamic>? ?? [];
    for (final item in items) {
      final row = item as Map<String, dynamic>;
      final id = row['id'] as String?;
      if (id != null) {
        map[id] = row['verified'] == true;
      }
    }
    return AccountVerificationMap(map);
  }

  AccountVerificationMap withEmergencyVerified(bool verified) {
    return AccountVerificationMap({..._verifiedById, 'emergency': verified});
  }
}
