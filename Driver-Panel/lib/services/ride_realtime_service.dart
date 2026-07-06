import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wavego_driver/core/config/app_config.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';

class RideRealtimeService {
  RideRealtimeService(this._tokenStore);

  final AuthTokenStore _tokenStore;
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  String? _subscribedRideId;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  Future<void> connect() async {
    if (_channel != null) return;
    final token = await _tokenStore.readAccessToken();
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
        } catch (_) {}
      },
      onError: (_) {},
      onDone: () {
        _channel = null;
        _subscribedRideId = null;
      },
      cancelOnError: false,
    );

    Timer.periodic(const Duration(seconds: 20), (t) {
      if (_channel == null) {
        t.cancel();
        return;
      }
      send({'event': 'ping'});
    });

    final rideId = _subscribedRideId;
    if (rideId != null && rideId.isNotEmpty) {
      subscribeRide(rideId);
    }
  }

  void subscribeRide(String rideId) {
    _subscribedRideId = rideId;
    send({'event': 'subscribe_ride', 'ride_id': rideId});
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
    _subscribedRideId = null;
    await _controller.close();
  }
}

final rideRealtimeProvider = Provider<RideRealtimeService>((ref) {
  final svc = RideRealtimeService(ref.watch(authTokenStoreProvider));
  ref.onDispose(() => svc.dispose());
  return svc;
});
