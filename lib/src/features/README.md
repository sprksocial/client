# Feature Development Guide

This directory contains feature modules organized according to the feature-first architecture pattern. Each feature is a self-contained module with its own data, business logic, and UI components.

# Glossary

- **Dependency Injection (DI)**: A technique where one object supplies the dependencies of another object. In this app, GetIt is used to provide instances of services and repositories where needed without tight coupling.
- **Data Layer**: The part of the app that manages data operations, including API calls, local storage, and data transformations. It contains repositories and models.
- **Models**: Classes that represent data structures used throughout the app. In this project, models are created using Freezed for immutability and type safety.
- **Repository**: The class that manages data operations for a specific feature. It abstracts the data source (API, local storage, etc.) from the rest of the app, making it easier to change the data source without affecting other parts. Basically, it's the part that handles the data directly.

- **Provider**: In Riverpod, a container for a piece of state that can be accessed and observed by UI components. Providers can depend on other providers to create a reactive graph. Providers use repositories to get data. Widgets use providers to manage state. Widgets are not supposed to use repositories directly.
- **Riverpod**: A state management library that provides reactive programming patterns. It offers better type safety and dependency management than the original Provider package.
- **FutureProvider**: A Riverpod provider specifically for handling asynchronous data like API calls. It manages loading, error, and success states automatically.
- **StateNotifier**: A class that holds and mutates state in a controlled way, notifying listeners of changes.
- **AsyncValue**: A value that represents asynchronous data with three possible states: loading, error, or data. Used with Riverpod to handle asynchronous operations elegantly.
- **ConsumerWidget**: A Flutter widget that can watch Riverpod providers and rebuild when their state changes.

- **Screen**: A screen is a page in the app. It is a widget that can be navigated to.
- **Page**: A page is a screen that is a part of a feature. It is registered in `core/router/pages.dart`.
- **Route**: A definition of a page in the app and how to navigate to it. It is registered in `core/router/app_router.dart`.

External data (API, local storage, etc.) -> Repository -> Provider -> Widget

Repositories get the data directly
Providers get repositories from the DI container (GetIt)
Widgets use ref.watch(provider) (or ref.read(provider)) to get and manipulate the data

## Feature Structure

Each feature should follow this structure:

```
feature_name/
├── data/                 # Data layer
│   ├── repositories/     # Repositories for data access
│   │   └── feature_repository.dart
│   └── models/           # Data models using Freezed
│       └── feature_model.dart
├── providers/            # Riverpod providers
│   └── feature_providers.dart
└── ui/                   # UI components
    ├── pages/            # Full pages/screens
    │   └── feature_page.dart
    └── widgets/          # Feature-specific widgets
        └── feature_widget.dart
```

## Creating a New Feature

### 1. Initial Setup

1. Create the feature directory structure

2. Define your data models first:
   ```dart
   // lib/src/features/feature_name/data/models/feature_model.dart
   import 'package:freezed_annotation/freezed_annotation.dart';
   import 'package:flutter/foundation.dart';
   
   part 'feature_model.freezed.dart';
   part 'feature_model.g.dart';
   
   @freezed
   class FeatureModel with _$FeatureModel {
     const factory FeatureModel({
       required String id,
       required String name,
       // Other properties
     }) = _FeatureModel;
     
     factory FeatureModel.fromJson(Map<String, dynamic> json) => 
         _$FeatureModelFromJson(json);
   }
   ```

3. Create the repository:
   ```dart
   // lib/src/features/feature_name/data/repositories/feature_repository.dart
   import '../models/feature_model.dart';
   
   abstract class FeatureRepository {
     Future<List<FeatureModel>> getFeatures();
     // Other methods
   }
   
   class FeatureRepositoryImpl implements FeatureRepository {
     @override
     Future<List<FeatureModel>> getFeatures() async {
       // Implementation
     }
     // Other methods
   }
   ```

### 2. Providers

Create Riverpod providers for your feature:

```dart
// lib/src/features/feature_name/providers/feature_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/feature_repository.dart';
import '../data/models/feature_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
Future<FeatureRepository> featureRepository(FeatureRepositoryRef ref) {
  return FeatureRepositoryImpl();
}

@riverpod
Future<List<FeatureModel>> features(FeaturesRef ref) {
  final repository = ref.watch(featureRepositoryProvider);
  return repository.getFeatures();
}
```

### 3. UI Components

1. Create pages (screens):
   ```dart
   // lib/src/features/feature_name/ui/pages/feature_page.dart
   import 'package:auto_route/auto_route.dart';
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import '../../providers/feature_providers.dart';
   import '../widgets/feature_widget.dart';
   
   @RoutePage()
   class FeaturePage extends ConsumerWidget {
     const FeaturePage({super.key});
     
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final featuresAsync = ref.watch(featuresProvider);
       
       return Scaffold(
         appBar: AppBar(title: const Text('Feature')),
         body: featuresAsync.when(
           data: (features) => ListView.builder(
             itemCount: features.length,
             itemBuilder: (context, index) => FeatureWidget(feature: features[index]),
           ),
           loading: () => const Center(child: CircularProgressIndicator()),
           error: (error, stackTrace) => Center(child: Text('Error: $error')),
         ),
       );
     }
   }
   ```

2. Create widgets:
   ```dart
   // lib/src/features/feature_name/ui/widgets/feature_widget.dart
   import 'package:flutter/material.dart';
   import '../../data/models/feature_model.dart';
   
   class FeatureWidget extends StatelessWidget {
     final FeatureModel feature;
     
     const FeatureWidget({super.key, required this.feature});
     
     @override
     Widget build(BuildContext context) {
       return ListTile(
         title: Text(feature.name),
         // Other UI elements
       );
     }
   }
   ```

### 4. Adding to the Router

After creating your feature page, add it to the router configuration:

1. First, add your page to `lib/src/core/routing/pages.dart`:
   ```dart
   export 'package:spark/src/features/feature_name/ui/pages/feature_page.dart';
   ```

2. Add the route to `lib/src/core/routing/app_router.dart`:
   ```dart
   @AutoRouterConfig()
   class AppRouter extends _$AppRouter {
     @override
     List<AutoRoute> get routes => [
       // Existing routes...
       
       // Add your new feature route
       AutoRoute(page: FeatureRoute.page, path: '/feature'),
     ];
   }
   ```

3. Run code generation:
   ```bash
   dart run build_runner watch
   ```

## Common Issues and Solutions

### Annoying generated files

Add this to your VSCode settings.json:

```json
"explorer.fileNesting.patterns": {
    "*.dart": "${capture}.freezed.dart, ${capture}.g.dart, ${capture}.gr.dart",
},
"explorer.fileNesting.enabled": true,
"explorer.fileNesting.expand": false
```

### Circular Dependencies

If you encounter circular dependencies between providers, consider:
- Creating a higher-level provider that combines the dependent providers
- Using callbacks to break the dependency cycle

### Provider Lifecycle

- Use `@riverpod` for providers that should be re-created when no longer used
- Use `@riverpod(keepAlive: true)` for providers that need to be kept alive

### Navigation

- For deep linking, ensure paths are properly configured
- For passing parameters, use route parameters in the path or query parameters

## Examples

For reference implementations, check:
- `lib/src/features/profile` - User profile feature

