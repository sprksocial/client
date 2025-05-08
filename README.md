# Spark Social

A decentralized social network for video sharing built on the AT Protocol, putting users in control of their digital presence and data.

![Spark Logo](https://static.sprk.so/branding/logo-horizontal-t6.png)

## Spark Your Creativity

Share videos freely while maintaining complete control over your data. Break free from corporate control and gain digital autonomy.

## About Spark

We are building a decentralized social network on the AT Protocol, empowering users to share content without compromising privacy or control. With Spark, you own your data and decide how it's used.

## Core Principles

- **Decentralized Network**: Built on the AT Protocol, giving you full control over your digital presence
- **User-First Approach**: Your data belongs to you, share content freely without compromising privacy
- **Digital Autonomy**: Break free from corporate control and take charge of your online experience

## Features

- **Content Filters**: Customize your feed with advanced content filters
- **Moderation Lists**: Create and subscribe to moderation lists for a healthier online environment
- **Custom Feeds**: Build personalized feeds based on your interests and favorite creators
- **Music & Audio Gallery**: Platform for musicians to reach wider audiences and listeners to discover new talent
- **Built-in Video Editor**: Create and edit professional-quality videos directly in the app
- **Creative Effects**: Share your creativity with Spark effects or design your own
- **Full Content Control**: You decide what to share and with whom
- **Social Media Detox**: Tools to reduce social media addiction and improve focus
- **Community Building**: Connect with like-minded individuals and build genuine communities
- **Human-first Discovery**: Find real creators and build genuine connections

## What Makes Spark Different?

- **Authenticity**: Rediscover genuine connections with real creators
- **Decentralization**: Break free from corporate control and gain digital autonomy
- **Custom Lexicon**: Our own lexicon provides more flexibility for content creators
- **Higher Content Limits**: Increased limits for video length and image quality
- **User Control**: You own your data and decide how it's used
- **Community Focus**: Build meaningful relationships in a supportive environment

## Screenshots

(Screenshots coming soon)

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- iOS/Android development environment

### Installation

1. Clone this repository
```bash
git clone https://github.com/sprksocial/spark-front-end.git
```

2. Navigate to the project directory
```bash
cd spark-social
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Technologies Used

- Flutter
- AT Protocol for decentralized social networking
- Cupertino (iOS-style) widgets
- Riverpod for state management
- AutoRoute for routing
- GetIt for dependency injection
- Freezed for data models
- Logger for logging
- Ionicons for beautiful icons
- Video player for media playback
- Camera for video recording
- Animation for smooth transitions

## Project Structure

```
  lib/
  ├── main.dart                  # App entry point
  └── src/
      ├── sprk_app.dart          # Main MaterialApp
      ├── core/                  # Shared code across features
      │   ├── config/            # Application-wide configurations
      │   ├── di/                # Dependency injection setup
      │   ├── network/           # ATProto client, API base
      │   ├── routing/           # AutoRoute setup
      │   ├── storage/           # Local storage utilities
      │   ├── theme/             # Theme definitions
      │   ├── l10n/              # Localization
      │   ├── widgets/           # Common widgets
      │   └── utils/             # Shared utilities
      └── features/              # Feature modules
          └── feature/                   
              ├── data/          # Data layer for this feature
              │   ├── repositories/   
              │   └── models/
              ├── providers/     # Riverpod providers
              └── ui/            # UI components
                  ├── pages/
                  └── widgets/
```

## Future Enhancements

- Enhanced data portability
- Custom server hosting options
- Advanced content creation tools
- Cross-platform federation
- Community moderation tools
- Expanded creative effects library

## Contributing

Contributions are welcome! Feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Connect With Us

- [Subscribe to Newsletter](https://spark-social-link-to-newsletter.com)
- [Learn More](https://spark-social-learn-more.com)
