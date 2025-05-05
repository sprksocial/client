# Migration Checklist

This document tracks the progress of migrating features from the old architecture to the new architecture based on the Flutter rule guidelines.

## Core Infrastructure
- [x] Set up project directory structure
- [x] Add required dependencies
- [x] Set up Riverpod providers
- [x] Set up GetIt dependency injection
- [x] Set up AutoRoute for navigation
- [x] Set up Freezed for data classes
- [x] App entry point (app.dart)

## Features to Migrate

### Authentication
- [ ] Login
- [ ] Registration
- [ ] Auth Service
- [ ] Identity Service
- [ ] Session Management

### Feed
- [ ] Feed Screen
- [ ] Feed Manager
- [ ] Feed Settings
- [ ] Post Rendering

### Profile
- [ ] Profile Screen
- [ ] Profile Service
- [ ] Edit Profile
- [ ] Profile Player

### Content Creation
- [ ] Create Video Screen
- [ ] Video Review
- [ ] Image Review
- [ ] Upload Service
- [ ] Camera Service

### Social Interactions
- [ ] Comments Service
- [ ] Actions Service (likes, shares, etc.)
- [ ] Messages Screen

### Search
- [ ] Search Screen
- [ ] Search Functionality

### Onboarding
- [ ] Onboarding Screen
- [ ] Onboarding Service
- [ ] Import Follows

### Moderation
- [ ] Moderation Service
- [ ] Label Service
- [ ] Labeler Manager

### Settings
- [ ] Settings Screens
- [ ] Settings Service

## Migration Status Legend
- ✅ Completed
- 🔄 In Progress
- ⏱️ Scheduled
- ❌ Blocked

## Completed Migrations
- ✅ Initial project structure setup
- ✅ Dependencies added
- ✅ GetIt service locator setup
- ✅ AutoRoute router setup
- ✅ Riverpod provider setup
- ✅ Freezed model setup

## Current Sprint Focus
- ✅ Set up core infrastructure
- ⏱️ Begin migration of authentication feature

## Notes for Team Members
- When adding new features, implement them in the new architecture under `lib/src/features/`
- Use the existing codebase for fixing critical bugs
- All new development should follow the architecture in `.cursor/rules/flutter.mdc`
- Run `flutter pub run build_runner build --delete-conflicting-outputs` after modifying any file that uses code generation 