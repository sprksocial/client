import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spark/src/core/auth/data/repositories/onboarding_repository.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';

void main() {
  test('profile creation records and rethrows repository failures', () async {
    final container = ProviderContainer.test(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(
          _FailingOnboardingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(onboardingStateProvider.future);
    final notifier = container.read(onboardingStateProvider.notifier);

    await expectLater(
      notifier.createCustomProfile(
        displayName: 'Alex Rivera',
        description: 'Imported biography',
      ),
      throwsStateError,
    );

    expect(container.read(onboardingStateProvider).hasError, isTrue);
  });
}

class _FailingOnboardingRepository implements OnboardingRepository {
  @override
  Future<void> createSparkProfile({
    required String displayName,
    required String description,
    dynamic avatar,
  }) async {
    throw StateError('Profile save failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
