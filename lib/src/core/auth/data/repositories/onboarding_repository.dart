abstract class OnboardingRepository {
  /// Checks if the current user has a Spark profile
  Future<bool> hasSparkProfile();

  /// Creates a Spark actor profile with custom values
  Future<void> createSparkProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  });
}
