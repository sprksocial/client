# Feature Development Guide

This directory contains feature modules organized according to the feature-first architecture pattern. Each feature is a self-contained module with its own data, business logic, and UI components.

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

final featureRepositoryProvider = Provider<FeatureRepository>((ref) {
  return FeatureRepositoryImpl();
});

final featuresProvider = FutureProvider<List<FeatureModel>>((ref) {
  final repository = ref.watch(featureRepositoryProvider);
  return repository.getFeatures();
});
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

1. First, add your page to core/router/pages.dart
   ```dart
   @RoutePage()
   class FeaturePage extends ConsumerWidget {
     // ...
   }
   ```

2. Add the route to `lib/src/core/router/app_router.dart`:
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
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Common Issues and Solutions

### Circular Dependencies

If you encounter circular dependencies between providers, consider:
- Creating a higher-level provider that combines the dependent providers
- Using callbacks to break the dependency cycle

### Provider Lifecycle

- Use `.autoDispose` for providers that should be re-created when no longer used
- Use `.family` for providers that need parameters

### Navigation

- For deep linking, ensure paths are properly configured
- For passing parameters, use route parameters in the path or query parameters

## Examples

For reference implementations, check:
- `lib/src/features/profile` - User profile feature

