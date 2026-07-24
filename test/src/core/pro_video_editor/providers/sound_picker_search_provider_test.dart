import 'dart:async';

import 'package:sprk_poptart/so/sprk/actor/defs.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:poptart/poptart.dart';
import 'package:poptart_lex/com/atproto/repo/strong_ref.dart';
import 'package:spark/src/core/network/atproto/data/models/models.dart';
import 'package:spark/src/core/network/atproto/data/repositories/sound_repository.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_provider.dart';
import 'package:spark/src/core/pro_video_editor/providers/sound_picker_search_state.dart';
import 'package:spark/src/core/utils/logging/log_service.dart';
import 'package:sprk_poptart/so/sprk/sound/defs/audio_details.dart';

void main() {
  late _FakeSoundRepository soundRepository;
  late _ManualDebounceScheduler debounceScheduler;

  AudioView audio(String id) {
    final blob = Blob.fromJson({
      r'$type': 'blob',
      'mimeType': 'audio/mpeg',
      'size': 42,
      'ref': {r'$link': 'bafkreigh2akiscaildc2'},
    });
    return AudioView(
      uri: AtUri.parse('at://did:plc:test123/so.sprk.sound.audio/$id'),
      cid: 'cid-$id',
      author: ProfileViewBasic(did: 'did:plc:test123', handle: '$id.sprk.so'),
      record: AudioRecord(
        sound: blob,
        title: 'Sound $id',
        createdAt: DateTime.parse('2026-05-01T12:00:00.000Z'),
      ).toJson(),
      title: 'Sound $id',
      coverArt: 'https://example.com/$id.jpg',
      indexedAt: DateTime.parse('2026-05-01T12:00:00.000Z'),
      audio: 'https://example.com/$id.mp3',
    );
  }

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        soundPickerSearchDebounceSchedulerProvider.overrideWithValue(
          debounceScheduler.schedule,
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      soundPickerSearchProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    return container;
  }

  setUp(() async {
    await GetIt.I.reset();
    soundRepository = _FakeSoundRepository();
    debounceScheduler = _ManualDebounceScheduler();
    GetIt.I
      ..registerSingleton<LogService>(LogService())
      ..registerSingleton<SoundRepository>(soundRepository);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('blank query resets to trending sounds', () async {
    soundRepository.trendingResponses.add(
      TrendingAudiosResponse(audios: [audio('trend-one')], cursor: 'more'),
    );
    soundRepository.trendingResponses.add(
      TrendingAudiosResponse(audios: [audio('trend-two')]),
    );

    final container = createContainer();
    await _waitForState(container, (state) => !state.isLoading);

    expect(
      container.read(soundPickerSearchProvider).audios.single.title,
      'Sound trend-one',
    );

    container.read(soundPickerSearchProvider.notifier).updateQuery('   ');
    await _waitForState(container, (state) => !state.isLoading);

    final state = container.read(soundPickerSearchProvider);
    expect(state.query, isEmpty);
    expect(state.audios.single.title, 'Sound trend-two');
    expect(soundRepository.searchCalls, isEmpty);
  });

  test('debounced query calls searchAudios', () async {
    soundRepository.trendingResponses.add(
      const TrendingAudiosResponse(audios: []),
    );
    soundRepository.searchResponses['lofi'] = SearchAudiosResponse(
      audios: [audio('lofi')],
    );

    final container = createContainer();
    await _waitForState(container, (state) => !state.isLoading);

    container.read(soundPickerSearchProvider.notifier).updateQuery('lofi');
    await debounceScheduler.runPending();

    final state = container.read(soundPickerSearchProvider);
    expect(soundRepository.searchCalls.single.query, 'lofi');
    expect(state.audios.single.title, 'Sound lofi');
    expect(state.isLoading, isFalse);
  });

  test('stale search responses do not overwrite newer results', () async {
    soundRepository.trendingResponses.add(
      const TrendingAudiosResponse(audios: []),
    );
    final slow = Completer<SearchAudiosResponse>();
    final fast = Completer<SearchAudiosResponse>();
    soundRepository.searchCompleters
      ..['slow'] = slow
      ..['fast'] = fast;

    final container = createContainer();
    await _waitForState(container, (state) => !state.isLoading);

    container.read(soundPickerSearchProvider.notifier).updateQuery('slow');
    final slowRequest = debounceScheduler.runPending();
    container.read(soundPickerSearchProvider.notifier).updateQuery('fast');
    final fastRequest = debounceScheduler.runPending();

    fast.complete(SearchAudiosResponse(audios: [audio('fast')]));
    await fastRequest;
    slow.complete(SearchAudiosResponse(audios: [audio('slow')]));
    await slowRequest;

    final state = container.read(soundPickerSearchProvider);
    expect(state.query, 'fast');
    expect(state.audios.single.title, 'Sound fast');
  });

  test('loadMore uses trending and search cursors correctly', () async {
    soundRepository.trendingResponses.add(
      TrendingAudiosResponse(audios: [audio('trend-one')], cursor: 'trend-2'),
    );
    soundRepository.trendingResponses.add(
      TrendingAudiosResponse(audios: [audio('trend-two')]),
    );
    soundRepository.searchResponses['mix'] = SearchAudiosResponse(
      audios: [audio('mix-one')],
      cursor: 'mix-2',
    );
    soundRepository.searchResponses['mix|mix-2'] = SearchAudiosResponse(
      audios: [audio('mix-two')],
    );

    final container = createContainer();
    await _waitForState(container, (state) => !state.isLoading);

    await container.read(soundPickerSearchProvider.notifier).loadMore();
    expect(soundRepository.trendingCursors, [null, 'trend-2']);
    expect(container.read(soundPickerSearchProvider).audios, hasLength(2));

    await container.read(soundPickerSearchProvider.notifier).submitQuery('mix');
    await container.read(soundPickerSearchProvider.notifier).loadMore();

    expect(soundRepository.searchCalls.map((call) => call.cursor), [
      null,
      'mix-2',
    ]);
    expect(container.read(soundPickerSearchProvider).audios, hasLength(2));
  });
}

Future<void> _waitForState(
  ProviderContainer container,
  bool Function(SoundPickerSearchState state) predicate,
) async {
  final completer = Completer<void>();
  final subscription = container.listen(soundPickerSearchProvider, (
    previous,
    next,
  ) {
    if (!completer.isCompleted && predicate(next)) {
      completer.complete();
    }
  }, fireImmediately: true);
  await completer.future;
  subscription.close();
}

class _ManualDebounceScheduler {
  _PendingDebounce? _pending;

  void Function() schedule(Duration delay, Future<void> Function() action) {
    expect(delay, const Duration(milliseconds: 350));
    final pending = _PendingDebounce(action);
    _pending = pending;
    return () => pending.isCanceled = true;
  }

  Future<void> runPending() {
    final pending = _pending;
    _pending = null;
    if (pending == null || pending.isCanceled) {
      throw StateError('No active debounce is pending');
    }
    return pending.action();
  }
}

class _PendingDebounce {
  _PendingDebounce(this.action);

  final Future<void> Function() action;
  bool isCanceled = false;
}

class _FakeSoundRepository implements SoundRepository {
  final List<TrendingAudiosResponse> trendingResponses = [];
  final List<String?> trendingCursors = [];
  final Map<String, SearchAudiosResponse> searchResponses = {};
  final Map<String, Completer<SearchAudiosResponse>> searchCompleters = {};
  final List<_SearchCall> searchCalls = [];

  @override
  Future<RepoStrongRef> createSound({
    required Blob sound,
    String? title,
    AudioDetails? details,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AudioPostsResponse> getAudioPosts(
    AtUri uri, {
    int limit = 50,
    String? cursor,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<TrendingAudiosResponse> getTrendingAudios({
    int limit = 50,
    String? cursor,
  }) async {
    trendingCursors.add(cursor);
    if (trendingResponses.isEmpty) {
      return const TrendingAudiosResponse(audios: []);
    }
    return trendingResponses.removeAt(0);
  }

  @override
  Future<SearchAudiosResponse> searchAudios(
    String query, {
    int limit = 25,
    String? cursor,
  }) async {
    searchCalls.add(_SearchCall(query, cursor));
    final key = cursor == null ? query : '$query|$cursor';
    final completer = searchCompleters[query];
    if (cursor == null && completer != null) {
      return completer.future;
    }
    return searchResponses[key] ?? const SearchAudiosResponse(audios: []);
  }
}

class _SearchCall {
  const _SearchCall(this.query, this.cursor);

  final String query;
  final String? cursor;
}
