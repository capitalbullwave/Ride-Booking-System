import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/repositories/auth_repository.dart';

/// Tracks whether the driver has a valid session for route guards.
class AuthSessionNotifier extends StateNotifier<bool> {
  AuthSessionNotifier(this._ref)
      : super(_ref.read(authTokenStoreProvider).accessToken?.isNotEmpty ?? false) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final token = await _ref.read(authTokenStoreProvider).readAccessToken();
    state = token != null && token.isNotEmpty;
  }

  void setAuthenticated(bool value) => state = value;

  Future<void> expireSession() async {
    await _ref.read(authRepositoryProvider).logout();
    state = false;
  }
}

final authSessionProvider =
    StateNotifierProvider<AuthSessionNotifier, bool>((ref) {
  return AuthSessionNotifier(ref);
});
