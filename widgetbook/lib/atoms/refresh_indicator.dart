import 'package:flutter/material.dart';
import 'package:spark/src/core/design_system/components/atoms/refresh_indicator.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Pull to refresh', type: DSRefreshIndicator)
Widget buildRefreshIndicatorUseCase(BuildContext context) {
  final reduceMotion = context.knobs.boolean(label: 'Reduce motion');
  final bouncing = context.knobs.boolean(label: 'Bouncing scroll physics');
  final edgeOffset = context.knobs.double.slider(
    label: 'Indicator top inset',
    initialValue: 0,
    min: 0,
    max: 120,
  );
  final l10n = AppLocalizations.of(context);

  return MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
    child: Scaffold(
      body: DSRefreshIndicator(
        edgeOffset: edgeOffset,
        onRefresh: () => Future<void>.delayed(const Duration(seconds: 2)),
        child: ListView(
          physics: bouncing
              ? const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                )
              : const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 96),
              child: Center(
                child: Text(
                  l10n.refreshIndicatorPull,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
