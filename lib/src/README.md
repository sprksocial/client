# New Architecture Structure

This directory contains the new architecture implementation following the guidelines in `.cursor/rules/flutter.mdc`.

## Directory Structure

```
lib/src/
├── core/                    # Shared code across features
│   ├── network/             # ATProto client, API base
│   ├── storage/             # Local storage utilities
│   ├── widgets/             # Common widgets
│   └── utils/               # Shared utilities
├── features/                # Feature modules
│   └── feature_name/        
│       ├── data/            # Data layer for this feature
│       │   ├── repositories/
│       │   └── models/
│       ├── providers/       # Riverpod providers
│       └── ui/              # UI components
│           ├── pages/
│           └── widgets/
├── app.dart                 # App entry point
├── migration_checklist.md   # Tracks migration progress
└── migration_strategy.md    # Explains migration approach
```

## Key Architectural Components

1. **Riverpod** for state management (replacing Provider)
2. **GetIt** for dependency injection
3. **Freezed** for immutable data models
4. **AutoRoute** for navigation

## How to Use This Architecture

### For Existing Features
- Check the `migration_checklist.md` to see if your feature has been migrated
- If not, continue using the old architecture until it's scheduled for migration

### For New Features
1. Create a new directory under `lib/src/features/`
2. Follow the structure outlined above
3. Use Riverpod providers for state management
4. Use Freezed for data classes
5. Inject dependencies with GetIt
6. Register routes with AutoRoute

### Migration Process
- Features will be migrated one at a time
- Once a feature is completely migrated, it will be integrated into the main app
- See `migration_strategy.md` for more details

## Further Reading
- [Riverpod Documentation](https://riverpod.dev/)
- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [AutoRoute Documentation](https://pub.dev/packages/auto_route) 