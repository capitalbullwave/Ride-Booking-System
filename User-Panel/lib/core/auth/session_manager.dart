import 'package:flutter/foundation.dart';

/// Notifies the app when refresh-token recovery fails and the user must log in again.
class SessionManager {
  VoidCallback? onSessionExpired;

  void notifySessionExpired() {
    onSessionExpired?.call();
  }
}
