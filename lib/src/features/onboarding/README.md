# Onboarding Feature

This feature handles user onboarding for Spark profiles, including profile creation and follow importing from Bluesky.

## Architecture

The onboarding feature follows a clean architecture approach:

- **Repository Pattern**: Separates data access logic from business logic
- **Riverpod Providers**: Manages state and dependency injection
- **Models**: Uses the Profile model from actor_models.dart and custom BskyFollows model

## Components

### Repository

- `OnboardingRepository`: Defines the contract for onboarding operations
- `OnboardingRepositoryImpl`: Implementation of the repository interface

### Models

- `BskyFollow`: Represents a single Bluesky follow entry
- `BskyFollows`: Collection of Bluesky follows with pagination support

### Providers

- `onboardingRepositoryProvider`: Provides the OnboardingRepository instance
- `hasSparkProfileProvider`: Checks if the user has a Spark profile
- `bskyProfileProvider`: Gets the user's Bluesky profile for import
- `bskyFollowsProvider`: Gets the user's Bluesky follows with pagination
- `onboardingStateProvider`: Manages the onboarding state and operations

## Usage Examples

### Check if user has a Spark profile

```dart
final hasProfile = ref.watch(hasSparkProfileProvider);

hasProfile.when(
  data: (hasProfile) {
    if (hasProfile) {
      // User already has a profile
    } else {
      // User needs to create a profile
    }
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

### Import Bluesky profile

```dart
final bskyProfile = ref.watch(bskyProfileProvider);
final onboardingState = ref.watch(onboardingStateProvider.notifier);

bskyProfile.when(
  data: (profile) {
    if (profile != null) {
      // Show profile data
      // When user confirms:
      onboardingState.importProfile(profile);
    }
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

### Get and display Bluesky follows

```dart
final bskyFollows = ref.watch(bskyFollowsProvider);

bskyFollows.when(
  data: (follows) {
    return ListView.builder(
      itemCount: follows.follows.length,
      itemBuilder: (context, index) {
        final follow = follows.follows[index];
        return ListTile(
          leading: follow.avatar != null 
            ? CircleAvatar(backgroundImage: NetworkImage(follow.avatar!))
            : CircleAvatar(child: Text(follow.handle[0])),
          title: Text(follow.displayName ?? follow.handle),
          subtitle: Text('@${follow.handle}'),
        );
      },
    );
  },
  loading: () => const CircularProgressIndicator(),
  error: (error, stackTrace) => Text('Error: $error'),
);
```

### Create custom profile

```dart
final onboardingState = ref.watch(onboardingStateProvider.notifier);

onboardingState.createCustomProfile(
  displayName: 'My Display Name',
  description: 'My profile description',
  avatar: avatarBlobReference,
);
```

### Import follows

```dart
final onboardingState = ref.watch(onboardingStateProvider.notifier);

// Import follows from Bluesky
onboardingState.importFollows();
``` 