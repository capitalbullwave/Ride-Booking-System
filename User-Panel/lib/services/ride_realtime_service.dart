import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/constants/app_constants.dart';
import 'package:wavego_user/core/storage/secure_storage_service.dart';

class RideRealtimeService {
  RideRealtimeService(this._storage);

  final SecureStorageService _storage;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  Future<void> connect() async {
    if (_channel != null) return;
    final token = await _storage.read(AppConstants.accessTokenKey);
    if (token == null || token.isEmpty) return;

    final url = AppConfig.rideWebsocketUrl(token);
    final channel = WebSocketChannel.connect(Uri.parse(url));
    _channel = channel;

    _sub = channel.stream.listen(
      (data) {
        try {
          final decoded = data is String ? jsonDecode(data) : data;
          if (decoded is Map<String, dynamic>) {
            _controller.add(decoded);
          } else if (decoded is Map) {
            _controller.add(decoded.cast<String, dynamic>());
          }
        } catch (_) {
          // Ignore malformed payloads.
        }
      },
      onError: (_) {},
      onDone: () {
        _channel = null;
      },
      cancelOnError: false,
    );

    // Keepalive: ping every 20s
    Timer.periodic(const Duration(seconds: 20), (t) {
      if (_channel == null) {
        t.cancel();
        return;
      }
      send({"event": "ping"});
    });
  }

  void subscribeRide(String rideId) {
    send({"event": "subscribe_ride", "ride_id": rideId});
  }

  void unsubscribeRide(String rideId) {
    send({"event": "unsubscribe_ride", "ride_id": rideId});
  }

  void send(Map<String, dynamic> data) {
    final ch = _channel;
    if (ch == null) return;
    try {
      ch.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
    await _controller.close();
  }
}

final rideRealtimeProvider = Provider<RideRealtimeService>((ref) {
  final svc = RideRealtimeService(ref.watch(secureStorageProvider));
  ref.onDispose(() => svc.dispose());
  return svc;
});

