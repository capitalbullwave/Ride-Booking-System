import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while the in-ride chat bottom sheet is open.
final rideChatSheetOpenProvider = StateProvider<bool>((ref) => false);
