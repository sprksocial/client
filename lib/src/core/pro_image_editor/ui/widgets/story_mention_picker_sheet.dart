import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spark/src/core/l10n/app_localizations.dart';
import 'package:spark/src/core/network/atproto/data/models/actor_models.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_provider.dart';
import 'package:spark/src/features/search/providers/actor_typeahead_state.dart';

Future<ProfileViewBasic?> showStoryMentionPickerSheet(BuildContext context) {
  return showModalBottomSheet<ProfileViewBasic>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF0F172A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _StoryMentionPickerSheet(),
  );
}

class _StoryMentionPickerSheet extends ConsumerStatefulWidget {
  const _StoryMentionPickerSheet();

  @override
  ConsumerState<_StoryMentionPickerSheet> createState() =>
      _StoryMentionPickerSheetState();
}

class _StoryMentionPickerSheetState
    extends ConsumerState<_StoryMentionPickerSheet> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typeaheadState = ref.watch(actorTypeaheadProvider);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x334B5563),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Mention someone',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Search for an account to place on your story.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: l10n.hintSearchByHandle,
              hintStyle: const TextStyle(color: Color(0xFF64748B)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFF111827),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0x334B5563)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0x99FFFFFF)),
              ),
            ),
            onChanged: (value) {
              ref.read(actorTypeaheadProvider.notifier).updateQuery(value);
            },
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: _ResultsList(typeaheadState: typeaheadState),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.typeaheadState});

  final ActorTypeaheadState typeaheadState;

  @override
  Widget build(BuildContext context) {
    if (typeaheadState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (typeaheadState.error != null) {
      return Center(
        child: Text(
          typeaheadState.error!,
          style: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      );
    }

    if (typeaheadState.query.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to find someone.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    if (typeaheadState.results.isEmpty) {
      return const Center(
        child: Text(
          'No people found for that search.',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: typeaheadState.results.length,
      separatorBuilder: (_, _) => const Divider(color: Color(0x1FFFFFFF)),
      itemBuilder: (context, index) {
        final actor = typeaheadState.results[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: const Color(0x1AFFFFFF),
            backgroundImage: actor.avatar != null
                ? NetworkImage(actor.avatar.toString())
                : null,
            child: actor.avatar == null
                ? const Icon(Icons.person_outline, color: Colors.white)
                : null,
          ),
          title: Text(
            actor.displayName ?? actor.handle,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '@${actor.handle}',
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
          onTap: () => Navigator.of(context).pop(actor),
        );
      },
    );
  }
}
