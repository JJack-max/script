import 'dart:async';
import 'package:local_auth/local_auth.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  Timer? _autoLockTimer;
  bool _isLocked = false;
  int _autoLockTimeoutSeconds = 300; // 5 minutes default
  
  bool get isLocked => _isLocked;
  
  // Set auto-lock timeout
  void setAutoLockTimeout(int seconds) {
    _autoLockTimeoutSeconds = seconds;
    // Restart timer if it's already running
    if (_autoLockTimer != null && _autoLockTimer!.isActive) {
      _resetAutoLockTimer();
    }
  }
  
  // Start auto-lock timer
  void startAutoLockTimer() {
    _resetAutoLockTimer();
  }
  
  // Stop auto-lock timer
  void stopAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;
  }
  
  // Reset auto-lock timer
  void _resetAutoLockTimer() {
    _autoLockTimer?.cancel();
    _autoLockTimer = Timer(Duration(seconds: _autoLockTimeoutSeconds), () {
      _isLocked = true;
    });
  }
  
  // Cancel auto-lock (when user interacts with app)
  void cancelAutoLock() {
    _resetAutoLockTimer();
    _isLocked = false;
  }
  
  // Lock immediately
  void lockNow() {
    stopAutoLockTimer();
    _isLocked = true;
  }
  
  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  // Get list of enrolled biometric types
  Future<List<BiometricType>> getEnrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to access passwords',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
  
  // Authenticate with device credentials (PIN, pattern, password)
  Future<bool> authenticateWithCredentials() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Enter your device PIN, pattern, or password to access passwords',
        options: const AuthenticationOptions(),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
}