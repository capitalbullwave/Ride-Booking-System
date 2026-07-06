import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class RideChatMessage {
  const RideChatMessage({
    required this.id,
    required this.rideId,
    required this.senderId,
    required this.senderType,
    required this.message,
    this.senderName,
    this.createdAt,
  });

  final String id;
  final String rideId;
  final String senderId;
  final String senderType;
  final String message;
  final String? senderName;
  final String? createdAt;

  factory RideChatMessage.fromJson(Map<String, dynamic> json) {
    return RideChatMessage(
      id: json['id']?.toString() ?? '',
      rideId: json['ride_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderType: json['sender_type']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      senderName: json['sender_name'] as String?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class RideChatService extends BaseApiService {
  RideChatService(super.dio, super.tokenStore);

  Future<List<RideChatMessage>> listMessages(String rideId) async {
    if (useMock) return const [];

    final data = await get<Map<String, dynamic>>(
      ApiEndpoints.rideMessages(rideId),
      parser: (raw) => raw as Map<String, dynamic>,
    );
    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(RideChatMessage.fromJson)
        .toList();
  }

  Future<RideChatMessage> sendMessage(String rideId, String message) async {
    if (useMock) {
      return RideChatMessage(
        id: 'mock-1',
        rideId: rideId,
        senderId: 'driver',
        senderType: 'driver',
        message: message,
        senderName: 'You',
      );
    }

    final data = await post<Map<String, dynamic>>(
      ApiEndpoints.rideMessages(rideId),
      data: {'message': message},
      parser: (raw) => raw as Map<String, dynamic>,
    );
    return RideChatMessage.fromJson(data['data'] as Map<String, dynamic>);
  }
}

final rideChatServiceProvider = Provider<RideChatService>((ref) {
  return RideChatService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
