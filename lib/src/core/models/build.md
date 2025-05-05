# Code Generation

To generate the Freezed and other auto-generated files for the new architecture, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- Freezed models
- AutoRoute router files
- Riverpod providers

Run this command whenever you make changes to files that require code generation. 