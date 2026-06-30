import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    @Default(false) bool read,
    @JsonKey(name: 'created_at') required String createdAt,
    Map<String, dynamic>? data,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

enum NotificationType {
  @JsonValue('ride')
  ride,
  @JsonValue('offer')
  offer,
  @JsonValue('bonus')
  bonus,
  @JsonValue('system')
  system,
  @JsonValue('expiry')
  expiry,
}
