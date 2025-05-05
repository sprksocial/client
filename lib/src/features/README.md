# Feature Migration

This directory will contain feature modules migrated from the old architecture according to the migration strategy.

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

## Migration Steps

1. **Identify Dependencies**:
   - List all services, models, and utilities required by the feature
   - Identify UI components and their interactions

2. **Create Data Layer**:
   - Define models using Freezed
   - Create repositories to access data

3. **Create Providers**:
   - Define Riverpod providers for state management
   - Use GetIt for dependency injection where needed

4. **Create UI Components**:
   - Rebuild UI components using the new architecture patterns
   - Consume providers for state management

