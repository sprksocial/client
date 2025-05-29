import 'dart:io';

import 'package:atproto_core/atproto_core.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sparksocial/src/core/network/data/models/feed_models.dart';

part 'feed_state.freezed.dart';

/// User opens the feed. Pages is the list of widgets that will be shown in the feed.
/// Feed shows CircularProgressIndicator.
/// The 10 most recent PostViews with cached video files that are not in pages are fetched from the database and added to the pages list.
/// Feed stops showing CircularProgressIndicator.
/// Repository fetches 10 PostViews and caches them in the database.
/// The videos of the 10 most recent PostViews without cached video files start downloading concurrently.
/// Whenever a video finishes downloading, it is added to the 
/// All videos start downloading concurrently
/// Whenever a video finishes downloading, count is incremented.
/// First two PostViews that finish downloading are added to the pages list (post widget, post model, file path)
/// Feed stops showing CircularProgressIndicator.
/// PostViews that finish downloading from now on are enqueued as (SizedBox, post model, file path)
/// Whenever the user scrolls down (index increments):
/// - If pages.length - index < 5, start fetching next batch
/// - pages[oldIndex - 1].page becomes a SizedBox
/// - pages[newIndex + 1].page becomes a new post widget
/// - If pages[newIndex] is a Video, start playing it
/// - If pages[oldIndex] is a Video, stop playing it
@freezed
abstract class FeedState with _$FeedState {
  factory FeedState({required bool active, required List<({Widget page, AtUri uri, File? file})> pages, required int index}) =
      _FeedState;
}
