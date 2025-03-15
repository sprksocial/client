# Profile Screen Components

This directory contains the refactored components for the Profile Screen, breaking down what was once a 1,000+ line file into smaller, more manageable components.

## Structure

### Utilities
- `TextFormatter` - Handles text formatting, including count formatting and username/link parsing
- `ProfileHelper` - Contains helper methods for profile-related functionality

### Components

#### Main Components
- `ProfileHeader` - Displays the profile image, user info, stats, and action buttons
- `ProfileTabs` - Renders the tab bar and handles tab selection
- `ProfileTabContent` - Manages content displayed based on the selected tab

#### Tab Components
- `VideosTab` - Grid of user's videos
- `PhotosTab` - Grid of user's photos
- `ContentGridTab` - Reusable grid component for favorites, reposts, and saved content

#### UI Components
- `VideoThumbnail` - Renders a thumbnail for videos with view count
- `AuthRequiredContent` - Shown when authentication is required to view content
- `ProfileLinks` - Renders links extracted from the user's description
- `ProfileStatItem` - Displays a single stat with count and label
- `ProfileActionButton` - Styled button for profile actions

## Benefits of Refactoring

1. **Maintainability**: Each component has a single responsibility
2. **Readability**: Shorter files are easier to understand
3. **Reusability**: Components like `ContentGridTab` can be reused across different tabs
4. **Testability**: Smaller components are easier to test in isolation
5. **Performance**: Smaller components optimize rendering by only updating what's necessary

## Usage

The main `ProfileScreen` class orchestrates these components, connecting them to the necessary services and handling state management.

```dart
// Example usage
ProfileHeader(
  profileData: extractedProfileData,
  isCurrentUser: isCurrentUser,
  isEarlySupporter: _isEarlySupporter,
  onEarlySupporterTap: () => _showEarlySupporterInfo(context),
  onEditTap: () => _handleEdit(),
  onShareTap: () => _handleShare(),
  onFollowTap: () => _handleFollow(),
  onSettingsTap: _handleSettingsTap,
), 