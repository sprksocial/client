import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/app_overlay_back_button.dart';
import 'package:spark/src/core/design_system/components/atoms/buttons/long_button.dart';
import 'package:spark/src/core/design_system/tokens/typography.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/core/routing/app_router.dart';
import 'package:spark/src/features/auth/providers/auth_providers.dart';
import 'package:spark/src/features/auth/providers/onboarding_providers.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_state.dart';
import 'package:spark/src/features/settings/providers/settings_provider.dart';

@RoutePage()
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _handleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _handleFocusNode = FocusNode();
  final _handleFieldKey = GlobalKey();
  final _handleSuggestionsLayerLink = LayerLink();
  late final ActorTypeahead _actorTypeaheadNotifier;
  bool _hasReceivedCallback = false;
  bool _isCompletingOAuth = false;
  bool _showHandleSuggestions = false;

  @override
  void initState() {
    super.initState();
    _actorTypeaheadNotifier = ref.read(actorTypeaheadProvider.notifier);
    _handleController.addListener(_onHandleChanged);
    _handleFocusNode.addListener(_onHandleFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TextInput.ensureInitialized();
    });
  }

  @override
  void dispose() {
    _actorTypeaheadNotifier.clear();
    _handleController.removeListener(_onHandleChanged);
    _handleFocusNode.removeListener(_onHandleFocusChanged);
    _handleController.dispose();
    _handleFocusNode.dispose();
    super.dispose();
  }

  void _onHandleChanged() {
    if (!_handleFocusNode.hasFocus || _hasReceivedCallback) {
      return;
    }

    final isLoading = ref.read(authProvider.select((state) => state.isLoading));
    if (isLoading || _isCompletingOAuth) {
      _hideHandleSuggestions(clearTypeahead: true);
      return;
    }

    final query = _handleController.text.trim();
    if (query.isEmpty) {
      _hideHandleSuggestions(clearTypeahead: true);
      return;
    }

    _actorTypeaheadNotifier.updateQuery(query);
    if (!_showHandleSuggestions) {
      setState(() {
        _showHandleSuggestions = true;
      });
    }
  }

  void _onHandleFocusChanged() {
    if (!_handleFocusNode.hasFocus) {
      _hideHandleSuggestions(clearTypeahead: true);
      return;
    }

    _onHandleChanged();
  }

  void _hideHandleSuggestions({required bool clearTypeahead}) {
    if (clearTypeahead) {
      _actorTypeaheadNotifier.clear();
    }

    if (!_showHandleSuggestions) {
      return;
    }

    setState(() {
      _showHandleSuggestions = false;
    });
  }

  Future<void> _onHandleSuggestionSelected(ProfileViewBasic actor) async {
    _handleController.text = actor.handle;
    _handleController.selection = TextSelection.collapsed(
      offset: actor.handle.length,
    );
    _hideHandleSuggestions(clearTypeahead: true);
    _handleFocusNode.unfocus();
    await _initiateOAuth();
  }

  Future<void> _initiateOAuth() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final handle = _handleController.text.trim();

      try {
        _hideHandleSuggestions(clearTypeahead: true);
        _handleFocusNode.unfocus();

        // Initiate OAuth flow - this returns the authorization URL
        final authUrl = await authNotifier.initiateOAuth(handle);

        if (!mounted) return;

        // Open the browser for OAuth authentication
        String callbackUrl;
        try {
          callbackUrl = await FlutterWebAuth2.authenticate(
            url: authUrl,
            callbackUrlScheme: 'sprk',
          );
        } on PlatformException catch (e) {
          if (e.code == 'CANCELED') {
            // User cancelled the OAuth flow - reset loading state
            if (!mounted) return;
            setState(() {
              _hasReceivedCallback = false;
              _isCompletingOAuth = false;
            });
            authNotifier.resetOAuthState();
            return;
          }
          // Re-throw other platform exceptions to be handled below
          rethrow;
        }

        if (!mounted) return;

        // Mark that we've received the callback - now we're completing OAuth
        setState(() {
          _hasReceivedCallback = true;
          _isCompletingOAuth = true;
        });

        // Complete the OAuth flow with the callback URL
        final completeResult = await authNotifier.completeOAuth(callbackUrl);

        if (!mounted) return;

        if (completeResult.isSuccess) {
          final hasSparkProfile = await ref
              .read(onboardingRepositoryProvider)
              .hasSparkProfile();

          if (!mounted) return;

          if (hasSparkProfile) {
            // Sync preferences from server before navigating to feed
            await ref
                .read(settingsProvider.notifier)
                .syncPreferencesFromServer();

            if (!mounted) return;

            context.router.replaceAll([const MainRoute()]);
          } else {
            context.router.replaceAll([const OnboardingRoute()]);
          }
        } else {
          // OAuth completion failed - reset callback state to show input again
          if (!mounted) return;
          setState(() {
            _hasReceivedCallback = false;
            _isCompletingOAuth = false;
          });
        }
      } catch (e) {
        // Reset loading state for any errors
        if (!mounted) return;
        setState(() {
          _hasReceivedCallback = false;
          _isCompletingOAuth = false;
        });
        final errorMessage = e is PlatformException
            ? 'Login failed: ${e.message ?? e.code}'
            : 'Login failed: $e';
        authNotifier.resetOAuthState(error: errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(
      authProvider.select((state) => state.isLoading),
    );
    final error = ref.watch(authProvider.select((state) => state.error));
    final typeaheadState = ref.watch(actorTypeaheadProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showHandleSuggestions =
        !isLoading &&
        !_hasReceivedCallback &&
        !_isCompletingOAuth &&
        _showHandleSuggestions &&
        typeaheadState.results.isNotEmpty;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final handleFieldWidth = MediaQuery.sizeOf(context).width - 48;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!_hasReceivedCallback) ...[
                              Text(
                                l10n.pageTitleSignIn,
                                style: AppTypography.displaySmallBold.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.messageEnterHandle,
                                style: AppTypography.textMediumMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                            ],

                            if (!_hasReceivedCallback) ...[
                              CompositedTransformTarget(
                                link: _handleSuggestionsLayerLink,
                                child: TextFormField(
                                  key: _handleFieldKey,
                                  controller: _handleController,
                                  focusNode: _handleFocusNode,
                                  enabled: !isLoading,
                                  decoration: InputDecoration(
                                    hintText: 'jerry.sprk.so',
                                    prefixIcon: Icon(
                                      FluentIcons.person_24_regular,
                                      color: colorScheme.primary,
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                  style: AppTypography.textMediumMedium
                                      .copyWith(color: colorScheme.onSurface),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [
                                    AutofillHints.username,
                                    AutofillHints.email,
                                  ],
                                  onEditingComplete: _initiateOAuth,
                                ),
                              ),
                            ],

                            if (error != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  switch (error) {
                                    final String e
                                        when e.contains(
                                          'must be a valid handle',
                                        ) =>
                                      l10n.errorInvalidHandle,
                                    final String e
                                        when e.contains('Failed to resolve') =>
                                      l10n.errorHandleNotFound,
                                    _ => error,
                                  },
                                  style: AppTypography.textSmallMedium.copyWith(
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                            if (_isCompletingOAuth)
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.errorCompletingSignIn,
                                      style: AppTypography.textMediumMedium
                                          .copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!_hasReceivedCallback && !_isCompletingOAuth)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                    child: AnimatedOpacity(
                      duration: reduceMotion
                          ? Duration.zero
                          : const Duration(milliseconds: 140),
                      opacity: isLoading ? 0.5 : 1.0,
                      child: LongButton(
                        label: l10n.buttonContinue,
                        onPressed: isLoading ? null : _initiateOAuth,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Back button in top-left corner
          Positioned(
            top: 0,
            left: 0,
            child: AppOverlayBackButton(color: colorScheme.onSurface),
          ),
          if (showHandleSuggestions)
            Positioned.fill(
              child: CompositedTransformFollower(
                link: _handleSuggestionsLayerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: handleFieldWidth,
                    child: _LoginHandleSuggestions(
                      state: typeaheadState,
                      reduceMotion: reduceMotion,
                      onSuggestionSelected: _onHandleSuggestionSelected,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoginHandleSuggestions extends StatefulWidget {
  const _LoginHandleSuggestions({
    required this.state,
    required this.reduceMotion,
    required this.onSuggestionSelected,
  });

  final ActorTypeaheadState state;
  final bool reduceMotion;
  final ValueChanged<ProfileViewBasic> onSuggestionSelected;

  @override
  State<_LoginHandleSuggestions> createState() =>
      _LoginHandleSuggestionsState();
}

class _LoginHandleSuggestionsState extends State<_LoginHandleSuggestions> {
  static const _rowMorphDuration = Duration(milliseconds: 180);

  int _nextSlotId = 0;
  late List<_SuggestionSlot> _slots = _createSlots(widget.state.results);
  Timer? _enteringTimer;

  @override
  void initState() {
    super.initState();
    _clearEnteringSoon();
  }

  @override
  void didUpdateWidget(covariant _LoginHandleSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextActors = widget.state.results;
    if (_sameActors(_slots.map((slot) => slot.actor).toList(), nextActors)) {
      return;
    }

    setState(() {
      for (var index = 0; index < nextActors.length; index++) {
        if (index < _slots.length) {
          _slots[index] = _slots[index].copyWith(
            actor: nextActors[index],
            isEntering: false,
            isRemoving: false,
          );
          continue;
        }

        _slots.add(
          _SuggestionSlot(
            id: _nextSlotId++,
            actor: nextActors[index],
            isEntering: true,
          ),
        );
      }

      for (var index = nextActors.length; index < _slots.length; index++) {
        _slots[index] = _slots[index].copyWith(
          isEntering: false,
          isRemoving: true,
        );
      }
    });

    if (widget.reduceMotion) {
      _pruneRemovedSlots();
      return;
    }

    _clearEnteringSoon();
  }

  @override
  void dispose() {
    _enteringTimer?.cancel();
    super.dispose();
  }

  List<_SuggestionSlot> _createSlots(List<ProfileViewBasic> actors) {
    return actors
        .map(
          (actor) => _SuggestionSlot(
            id: _nextSlotId++,
            actor: actor,
            isEntering: true,
          ),
        )
        .toList();
  }

  bool _sameActors(
    List<ProfileViewBasic> previous,
    List<ProfileViewBasic> next,
  ) {
    if (previous.length != next.length) {
      return false;
    }

    for (var index = 0; index < previous.length; index++) {
      if (previous[index].did != next[index].did) {
        return false;
      }
    }

    return true;
  }

  void _clearEnteringSoon() {
    _enteringTimer?.cancel();
    if (widget.reduceMotion) {
      return;
    }

    _enteringTimer = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _slots = [
          for (final slot in _slots)
            if (!slot.isRemoving) slot.copyWith(isEntering: false),
        ];
      });
    });
  }

  void _pruneRemovedSlots() {
    if (!mounted || !_slots.any((slot) => slot.isRemoving)) {
      return;
    }

    setState(() {
      _slots = [
        for (final slot in _slots)
          if (!slot.isRemoving) slot,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.state.query.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_slots.isEmpty) {
      return const SizedBox.shrink();
    }

    final panel = AnimatedSize(
      duration: widget.reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 252),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withAlpha(96)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: _slots.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: colorScheme.outline.withAlpha(48)),
          itemBuilder: (context, index) {
            final slot = _slots[index];
            return _AnimatedSuggestionSlot(
              key: ValueKey(slot.id),
              actor: slot.actor,
              isEntering: slot.isEntering,
              isRemoving: slot.isRemoving,
              reduceMotion: widget.reduceMotion,
              onRemoved: _pruneRemovedSlots,
              onTap: () => widget.onSuggestionSelected(slot.actor),
            );
          },
        ),
      ),
    );

    if (widget.reduceMotion) {
      return panel;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            alignment: Alignment.topCenter,
            scaleY: 0.96 + (0.04 * value),
            child: Transform.translate(
              offset: Offset(0, (value - 1) * 4),
              child: child,
            ),
          ),
        );
      },
      child: panel,
    );
  }
}

class _SuggestionSlot {
  const _SuggestionSlot({
    required this.id,
    required this.actor,
    this.isEntering = false,
    this.isRemoving = false,
  });

  final int id;
  final ProfileViewBasic actor;
  final bool isEntering;
  final bool isRemoving;

  _SuggestionSlot copyWith({
    ProfileViewBasic? actor,
    bool? isEntering,
    bool? isRemoving,
  }) {
    return _SuggestionSlot(
      id: id,
      actor: actor ?? this.actor,
      isEntering: isEntering ?? this.isEntering,
      isRemoving: isRemoving ?? this.isRemoving,
    );
  }
}

class _AnimatedSuggestionSlot extends StatelessWidget {
  const _AnimatedSuggestionSlot({
    required this.actor,
    required this.isEntering,
    required this.isRemoving,
    required this.reduceMotion,
    required this.onRemoved,
    required this.onTap,
    super.key,
  });

  final ProfileViewBasic actor;
  final bool isEntering;
  final bool isRemoving;
  final bool reduceMotion;
  final VoidCallback onRemoved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tile = AnimatedSwitcher(
      duration: reduceMotion
          ? Duration.zero
          : _LoginHandleSuggestionsState._rowMorphDuration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [...previousChildren, ?currentChild],
        );
      },
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _LoginHandleSuggestionTile(
        key: ValueKey(actor.did),
        actor: actor,
        onTap: onTap,
      ),
    );

    if (reduceMotion) {
      return isRemoving ? const SizedBox.shrink() : tile;
    }

    return TweenAnimationBuilder<double>(
      duration: _LoginHandleSuggestionsState._rowMorphDuration,
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: isRemoving ? 0 : 1),
      onEnd: isRemoving ? onRemoved : null,
      builder: (context, value, child) {
        final enteringOffset = isEntering ? (value - 1) * 8 : 0.0;
        final removingOffset = isRemoving ? (1 - value) * -8 : 0.0;

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: value.clamp(0.0, 1.0),
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, enteringOffset + removingOffset),
                child: child,
              ),
            ),
          ),
        );
      },
      child: tile,
    );
  }
}

class _LoginHandleSuggestionTile extends StatelessWidget {
  const _LoginHandleSuggestionTile({
    required this.actor,
    required this.onTap,
    super.key,
  });

  final ProfileViewBasic actor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: actor.avatar != null
                    ? NetworkImage(actor.avatar.toString())
                    : null,
                child: actor.avatar == null
                    ? Icon(
                        FluentIcons.person_24_regular,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actor.displayName ?? actor.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textMediumMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${actor.handle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textSmallMedium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FluentIcons.arrow_enter_20_regular,
                size: 18,
                color: colorScheme.onSurfaceVariant.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
