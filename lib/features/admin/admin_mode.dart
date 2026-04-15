import 'package:flutter/foundation.dart';

/// Controls whether admin is in admin mode or user mode.
/// Only relevant when user.role == 'admin'.
class AdminMode {
  AdminMode._();

  static final ValueNotifier<bool> notifier = ValueNotifier(true);

  static bool get isAdminMode => notifier.value;

  static void toggle() {
    notifier.value = !notifier.value;
  }

  static void setAdminMode(bool value) {
    notifier.value = value;
  }
}
