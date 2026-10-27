import 'package:flutter/services.dart';

abstract interface class SecureWindow {
  Future<void> setSecure(bool secure);
}

final class AndroidSecureWindow implements SecureWindow {
  static const _channel = MethodChannel('fintrack/window');

  @override
  Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      return;
    }
  }
}
