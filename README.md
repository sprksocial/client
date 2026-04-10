# Spark Social App

Welcome to the codebase for the Spark Social mobile app.

Get the Spark Social app:

- [iOS](https://apps.apple.com/us/app/spark-social-in-your-hands/id6743555448)
- [Android](https://play.google.com/store/apps/details?id=so.sprk.app)

## Overview

This repo contains the mobile client for Spark Social. This is a Flutter app,
written in Dart, using MaterialApp as its base.

Spark is an open source shortform social app for photos and videos built on AT
Protocol. It's an open alternative to closed platforms like Instagram and
Tiktok.

We support stories, reusable sounds, DMs, and we have a built-in photo and video
editor powered by [pro_image_editor](https://github.com/hm21/pro_image_editor).

## Structure

The app is organized with a feature-first structure and uses Riverpod + GetIt +
Freezed + AutoRoute. We also utilize the open source
[atproto.dart](https://github.com/myConsciousness/atproto.dart) client
libraries.

### Project Layout

```text
lib/
  main.dart
  src/
    core/        # shared infrastructure (network, routing, utils, theme, etc.)
    features/    # feature modules
      <feature>/
        data/
        providers/
        ui/
widgetbook/      # widgetbook workspace package
fonts/           # local font package
assets/          # local assets package
```

## Resources

Spark Social is built on [AT Protocol](https://atproto.com/), a protocol for
decentralized social networks. This allows for unprecidented amounts of
user-autonomy and data ownership, and ensures no one entity is in charge of the
network.

The lexicon schemas for the records published and APIs used by this app are
under the `so.sprk.*` namespace.

The API server or "AppView" this app uses can be found in the
[server repo](https://github.com/sprksocial/server), and contains the
`sprk.so.*` lexicon schemas used in this client.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT Licensed. See [LICENSE](LICENSE).
