import 'dart:math';

class PasswordGenerator {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _specialChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  /// Generates a random password based on the provided criteria
  static String generatePassword({
    int length = 16,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeDigits = true,
    bool includeSpecialChars = true,
    String customChars = '',
  }) {
    if (length <= 0) {
      throw ArgumentError('Password length must be greater than 0');
    }

    // Build character set based on options
    StringBuffer charSet = StringBuffer();
    
    if (includeLowercase) charSet.write(_lowercase);
    if (includeUppercase) charSet.write(_uppercase);
    if (includeDigits) charSet.write(_digits);
    if (includeSpecialChars) charSet.write(_specialChars);
    if (customChars.isNotEmpty) charSet.write(customChars);
    
    if (charSet.isEmpty) {
      throw ArgumentError('At least one character type must be included');
    }
    
    final chars = charSet.toString();
    final random = Random.secure();
    
    // Generate password
    StringBuffer password = StringBuffer();
    for (int i = 0; i < length; i++) {
      final randomIndex = random.nextInt(chars.length);
      password.write(chars[randomIndex]);
    }
    
    return password.toString();
  }
  
  /// Calculates password strength (0-100)
  static int calculatePasswordStrength(String password) {
    int strength = 0;
    
    // Length contributes up to 50 points
    if (password.length >= 8) strength += min(50, password.length * 2);
    
    // Character variety contributes up to 50 points
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) strength += 20;
    
    return min(100, strength);
  }
  
  /// Checks if password meets common security requirements
  static bool isPasswordSecure(String password) {
    // At least 8 characters
    if (password.length < 8) return false;
    
    // Contains lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) return false;
    
    // Contains uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    
    // Contains digit
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    
    // Contains special character
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) return false;
    
    return true;
  }
}