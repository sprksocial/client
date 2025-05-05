import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparksocial/src/core/di/service_locator.dart';

/// SprkApp is the root widget of the new architecture.
/// As features are migrated, they will be integrated here.
class SprkApp extends ConsumerWidget {
  const SprkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Spark',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Configure theme according to the app's design system
      ),
      home: const Scaffold(
        body: Center(
          child: Text('New Architecture Coming Soon'),
        ),
      ),
      // As features are migrated, this will be updated to use AutoRoute
    );
  }
}

/// This method configures all dependencies required for the new architecture.
/// It should be called before the app starts.
Future<void> configureDependencies() async {
  // Initialize GetIt
  await initServiceLocator();
}
