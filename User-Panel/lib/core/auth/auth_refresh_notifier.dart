import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Triggers GoRouter redirect re-evaluation after login/logout.
class AuthRefreshNotifier extends ChangeNotifier {
  void notifyAuthChanged() => notifyListeners();
}

final authRefreshNotifierProvider = Provider<AuthRefreshNotifier>((ref) {
  return AuthRefreshNotifier();
});
