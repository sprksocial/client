import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_button.dart';
import 'package:spark/src/core/design_system/tokens/colors.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';

enum FeedTerminalStateVariant { emptyFollowing, emptyFeed, caughtUp }

class FeedTerminalState extends StatelessWidget {
  const FeedTerminalState({
    required this.variant,
    required this.onRefresh,
    super.key,
    this.onExploreDiscover,
    this.onFindPeople,
    this.onImportFromBluesky,
  });

  final FeedTerminalStateVariant variant;
  final VoidCallback onRefresh;
  final VoidCallback? onExploreDiscover;
  final VoidCallback? onFindPeople;
  final VoidCallback? onImportFromBluesky;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, description) = switch (variant) {
      FeedTerminalStateVariant.emptyFollowing => (
        l10n.emptyFollowingFeedTitle,
        l10n.emptyFollowingFeedDescription,
      ),
      FeedTerminalStateVariant.emptyFeed => (
        l10n.emptyFeedTitle,
        l10n.emptyFeedDescription,
      ),
      FeedTerminalStateVariant.caughtUp => (
        l10n.messageAllCaughtUp,
        l10n.caughtUpFeedDescription,
      ),
    };

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 96),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineSmallBold.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.textMediumMedium.copyWith(
                color: AppColors.grey300,
              ),
            ),
            const SizedBox(height: 28),
            ..._actions(l10n),
          ],
        ),
      ),
    );
    if (variant != FeedTerminalStateVariant.caughtUp) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.black),
      child: SafeArea(child: Center(child: content)),
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final actions = <Widget>[];
    if (variant == FeedTerminalStateVariant.emptyFollowing) {
      if (onImportFromBluesky != null) {
        actions.add(
          AppButton(
            label: l10n.buttonImportFromBluesky,
            onPressed: onImportFromBluesky,
            fullWidth: true,
          ),
        );
      }
      if (onFindPeople != null) {
        if (actions.isNotEmpty) actions.add(const SizedBox(height: 12));
        actions.add(
          AppButton(
            label: l10n.buttonFindPeople,
            onPressed: onFindPeople,
            variant: onImportFromBluesky == null
                ? AppButtonVariant.primary
                : AppButtonVariant.secondary,
            fullWidth: true,
          ),
        );
      }
    } else {
      actions.add(
        AppButton(
          label: l10n.buttonRefresh,
          onPressed: onRefresh,
          fullWidth: true,
        ),
      );
    }

    if (onExploreDiscover != null) {
      if (actions.isNotEmpty) actions.add(const SizedBox(height: 12));
      actions.add(
        AppButton(
          label: l10n.buttonExploreDiscover,
          onPressed: onExploreDiscover,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
        ),
      );
    }
    return actions;
  }
}
