import 'package:atproto/core.dart';

/// Utilities for JWT token handling
class JwtUtils {
  /// Checks if a token is expired or about to expire (within 5 minutes)
  /// 
  /// [token] - The JWT token to check
  static bool isTokenExpired(Jwt token) {
    return DateTime.now().isAfter(token.exp.subtract(const Duration(minutes: 5)));
  }
} 