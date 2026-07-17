import 'package:url_launcher/url_launcher.dart';

/// Opens external maps, phone dialer, and SMS for ride-related actions.
class NavigationLauncher {
  NavigationLauncher._();

  static Future<bool> openMaps({
    required double lat,
    required double lng,
    String? label,
    String app = 'Google Maps',
    List<({double lat, double lng})> waypoints = const [],
  }) async {
    final encodedLabel = label != null ? Uri.encodeComponent(label) : null;

    // Multi-stop: use Google Maps directions with waypoints.
    if (waypoints.isNotEmpty && app != 'MapMyIndia') {
      final wp = waypoints
          .map((w) => '${w.lat},${w.lng}')
          .join('|');
      final multi = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng'
        '&waypoints=$wp'
        '&travelmode=driving',
      );
      if (await canLaunchUrl(multi)) {
        return launchUrl(multi, mode: LaunchMode.externalApplication);
      }
    }

    final Uri primary;
    if (app == 'MapMyIndia') {
      primary = Uri.parse(
        'https://www.mapmyindia.com/?lat=$lat&lng=$lng'
        '${encodedLabel != null ? '&title=$encodedLabel' : ''}',
      );
    } else {
      primary = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    }

    if (await canLaunchUrl(primary)) {
      return launchUrl(primary, mode: LaunchMode.externalApplication);
    }

    final web = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'
      '${encodedLabel != null ? '&destination_place_id=$encodedLabel' : ''}',
    );
    return launchUrl(web, mode: LaunchMode.externalApplication);
  }

  static Future<bool> callPhone(String phone) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.isEmpty) return false;
    final uri = Uri.parse('tel:$normalized');
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }

  static Future<bool> sendSms(String phone, {String? body}) async {
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (normalized.isEmpty) return false;
    final uri = body == null
        ? Uri.parse('sms:$normalized')
        : Uri.parse('sms:$normalized?body=${Uri.encodeComponent(body)}');
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri);
  }
}
