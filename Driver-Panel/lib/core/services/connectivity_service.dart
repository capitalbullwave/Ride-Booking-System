import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.ethernet,
    );
  }

  void dispose() => _subscription?.cancel();
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});

final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield await service.isConnected;
  yield* service.onConnectivityChanged;
});
