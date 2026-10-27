import 'package:local_auth/local_auth.dart';

enum AuthOutcome { success, failed, unavailable }

abstract interface class Authenticator {
  Future<AuthOutcome> authenticate(String reason);
}

final class DeviceAuthenticator implements Authenticator {
  DeviceAuthenticator() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return AuthOutcome.unavailable;
      }
      final ok = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? AuthOutcome.success : AuthOutcome.failed;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.noCredentialsSet => AuthOutcome.unavailable,
        _ => AuthOutcome.failed,
      };
    }
  }
}
