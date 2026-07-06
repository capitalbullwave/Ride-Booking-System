import 'package:url_launcher/url_launcher.dart';

class NavigationLauncher {
  NavigationLauncher._();

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
