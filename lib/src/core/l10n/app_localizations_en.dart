// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonBlock => 'Block';

  @override
  String get buttonUnblock => 'Unblock';

  @override
  String get buttonReport => 'Report';

  @override
  String get buttonReportProfile => 'Report Profile';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonRemove => 'Remove';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get buttonTryAgain => 'Try again';

  @override
  String get buttonGoBack => 'Go Back';

  @override
  String get buttonAllowAccess => 'Allow Access';

  @override
  String get buttonOpenSettings => 'Open Settings';

  @override
  String get buttonSubmit => 'Submit';

  @override
  String get inputErrorRequired => 'This field is required';

  @override
  String get inputErrorEmail => 'Please enter a valid email address';

  @override
  String get loading => 'Loading...';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get pageTitleSettings => 'Settings';

  @override
  String get pageTitleStoryManager => 'Story Manager';

  @override
  String get pageTitleSound => 'Sound';

  @override
  String get pageTitleYourFeeds => 'Your Feeds';

  @override
  String get pageTitleBlockedUsers => 'Blocked Users';

  @override
  String get pageTitleEditProfile => 'Edit Profile';

  @override
  String get pageTitleCompleteProfile => 'Complete your profile';

  @override
  String onboardingStepCount(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingIntroStepTitle => 'Set up your profile';

  @override
  String get onboardingIntroTitle => 'Let’s get your profile ready.';

  @override
  String get onboardingIntroDescription =>
      'Next you’ll add a profile photo, display name, and bio. It only takes a minute, and you can edit everything later.';

  @override
  String get onboardingAvatarStepTitle => 'Add a profile photo';

  @override
  String get onboardingNameStepTitle => 'Add your display name';

  @override
  String get onboardingBioStepTitle => 'Add a bio';

  @override
  String get onboardingAvatarEyebrow => 'Profile photo';

  @override
  String get onboardingAvatarTitle => 'Make Spark feel like you.';

  @override
  String get onboardingAvatarSubtitle =>
      'Start with the avatar people will recognize in feeds, comments, and profiles.';

  @override
  String get onboardingBskyAutofill =>
      'Imported from your Bluesky profile. You can change it.';

  @override
  String get onboardingUseBskyAvatar => 'Use Bluesky avatar';

  @override
  String get onboardingNameEyebrow => 'Display name';

  @override
  String get onboardingNameTitle => 'What should people call you?';

  @override
  String get onboardingNameSubtitle =>
      'Use a real name, a handle, or whatever makes your posts feel unmistakably yours.';

  @override
  String get onboardingNamePreviewHint =>
      'This is the name people see first, so keep it clear and easy to recognize.';

  @override
  String get onboardingBioEyebrow => 'Bio';

  @override
  String get onboardingBioTitle => 'Write the first line of your profile.';

  @override
  String get onboardingBioSubtitle =>
      'A sentence is enough. Tell people what you post, what you like, or why they should follow along.';

  @override
  String get onboardingBioTip =>
      'You can always polish this later from your profile settings.';

  @override
  String get onboardingDisplayNameTooLong =>
      'Display Name cannot exceed 64 characters';

  @override
  String get onboardingBioTooLong => 'Bio cannot exceed 256 characters';

  @override
  String get pageTitleLabelerSettings => 'Labeler Settings';

  @override
  String get pageTitleLabelers => 'Labelers';

  @override
  String get pageTitleResult => 'Result';

  @override
  String get dialogDeleteStory => 'Delete Story';

  @override
  String get dialogDeleteStoryConfirm =>
      'Are you sure you want to delete this story?';

  @override
  String get dialogRemoveLabeler => 'Remove Labeler';

  @override
  String get dialogRemoveLabelerConfirm =>
      'Are you sure you want to remove this labeler?';

  @override
  String get dialogRemoveFeed => 'Remove Feed';

  @override
  String get dialogDeletePost => 'Delete Post';

  @override
  String get dialogDeleteComment => 'Delete Comment';

  @override
  String get emptyNoUsers => 'No users to display.';

  @override
  String get emptyNoBlockedUsers => 'No blocked users.';

  @override
  String get emptyNoStories => 'No stories';

  @override
  String get emptyNoComments => 'No comments yet.';

  @override
  String get emptyNoCrosspostComments => 'No crosspost comments yet.';

  @override
  String get emptyNoLabelers => 'No Labelers';

  @override
  String get emptyNoLabelersDescription =>
      'Add labelers to customize content moderation';

  @override
  String get emptyDiscoverContent => 'Discover new content';

  @override
  String get emptyNoMedia => 'No photos or videos found...';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorLoadingFeed => 'Error loading feed';

  @override
  String get errorUpdatingFeeds => 'Could not update feeds. Try again.';

  @override
  String get errorLoadingSound => 'Error loading sound';

  @override
  String get errorSearchingSounds => 'Error searching sounds';

  @override
  String get errorLoadingReposts => 'Error loading reposts';

  @override
  String get errorLoadingLikes => 'Error loading likes';

  @override
  String get pageTitlePostLikes => 'Likes';

  @override
  String get emptyNoPostLikes => 'No likes yet';

  @override
  String get errorLoadingPosts => 'Error loading posts';

  @override
  String get hintSearchUsersPosts => 'Search users, posts...';

  @override
  String get hintSearchUsers => 'Search users';

  @override
  String get hintMessage => 'Message...';

  @override
  String get hintTypeMessage => 'Type a message...';

  @override
  String get hintAddDescription => 'Add a caption... (optional)';

  @override
  String get hintAddAltText => 'Add alt text';

  @override
  String get hintDisplayName => 'Display Name';

  @override
  String get hintBio => 'Bio';

  @override
  String get hintDidOrHandle => 'DID or Handle';

  @override
  String get hintDidOrHandleExample => 'did:plc:... or @handle.bsky.social';

  @override
  String get hintAdditionalDetails => 'Additional details (optional)';

  @override
  String get hintImageDescription => 'Image Description';

  @override
  String get messagePleaseLogin => 'Please log in to view your profile';

  @override
  String get messagePleaseLoginBlocked => 'Please log in to view blocked users';

  @override
  String messagePostedAgo(String time) {
    return 'Posted $time ago';
  }

  @override
  String messageShowReplies(int count) {
    return 'Show $count replies';
  }

  @override
  String get messageAutoDeleteStories => 'Stories auto-delete after 24 hours';

  @override
  String get messageAutoDeleteStoriesDescription =>
      'Stories are public and stored on your PDS indefinitely. Enable this so the app auto deletes them forever after 24h. Enabling this will also execute an initial cleanup of any stories older than 24h.';

  @override
  String get messageExportingVideo => 'Exporting video…';

  @override
  String messageStoryNumber(int number) {
    return 'Story $number';
  }

  @override
  String get tooltipManage => 'Manage';

  @override
  String get tooltipDelete => 'Delete';

  @override
  String get tooltipRetry => 'Retry';

  @override
  String get tooltipLabelSettings => 'Label settings';

  @override
  String get tooltipRemoveLabeler => 'Remove labeler';

  @override
  String get tooltipRevert => 'Revert';

  @override
  String get labelGenerationTime => 'Generation time:';

  @override
  String get labelDuration => 'Duration:';

  @override
  String get labelSize => 'Size:';

  @override
  String get labelResolution => 'Resolution:';

  @override
  String get labelAddLabeler => 'Add Labeler';

  @override
  String labelCharacters(int count) {
    return '$count/1000';
  }

  @override
  String get categoryViolence => 'Violence';

  @override
  String get categorySexualContent => 'Sexual Content';

  @override
  String get categoryChildSafety => 'Child Safety';

  @override
  String get categoryHarassment => 'Harassment';

  @override
  String get categoryMisleading => 'Misleading';

  @override
  String get categoryRuleViolations => 'Rule Violations';

  @override
  String get categorySelfHarm => 'Self-Harm';

  @override
  String get categoryOther => 'Other';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonGetStarted => 'Get Started';

  @override
  String get buttonHaveAccount => 'I have an Atmosphere Account';

  @override
  String get buttonOpen => 'Open';

  @override
  String get buttonPost => 'Post';

  @override
  String get buttonDone => 'Done';

  @override
  String get buttonAddSound => 'Add sound';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonShare => 'Share';

  @override
  String get buttonCopied => 'Copied';

  @override
  String get buttonCopyLink => 'Copy link';

  @override
  String get errorInvalidHandle => 'Invalid handle';

  @override
  String get errorHandleNotFound => 'Could not find this handle';

  @override
  String get errorCompletingSignIn => 'Completing sign in...';

  @override
  String get errorProfileNotFound => 'Profile not found';

  @override
  String get errorLoadingPost => 'Error loading post';

  @override
  String get errorLoadingMessages => 'Failed to load messages';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get messageUnsupported => 'Unsupported message';

  @override
  String get errorLoadingConversations => 'Failed to load conversations';

  @override
  String get errorUnableToOpenLink => 'Unable to open link right now.';

  @override
  String get errorLoadingLabelerSettings => 'Error Loading Labeler Settings';

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get hintAddComment => 'Add a comment...';

  @override
  String get hintSearchUsersMessages => 'Search users';

  @override
  String get dialogDeleteCommentConfirm =>
      'Are you sure you want to delete this comment? This action cannot be undone.';

  @override
  String get dialogDeletePostConfirm =>
      'Are you sure you want to delete this post? This action cannot be undone.';

  @override
  String get dialogBlockUser => 'Block User';

  @override
  String get dialogBlockUserConfirm =>
      'Are you sure you want to block this user? You will no longer see their posts.';

  @override
  String get dialogUnblockUser => 'Unblock User';

  @override
  String get dialogUnblockUserConfirm =>
      'Are you sure you want to unblock this user?';

  @override
  String dialogRemoveFeedConfirm(String name) {
    return 'Are you sure you want to remove \"$name\"?';
  }

  @override
  String get dialogOpenBlueskyAccount => 'Open Bluesky account management?';

  @override
  String dialogOpenBlueskyAccountDescription(String pdsUrl) {
    return 'This opens the Bluesky account management screen. You may have to log in again.\n\nIf prompted for an account provider, use:\n$pdsUrl';
  }

  @override
  String get pageTitleReplies => 'Replies';

  @override
  String get pageTitleReviewVideo => 'Review Video';

  @override
  String get pageTitleReviewImagePost => 'Review Image Post';

  @override
  String get pageTitleLegal => 'Legal';

  @override
  String get pageTitleFollowers => 'Followers';

  @override
  String get pageTitleKnownFollowers => 'Known followers';

  @override
  String get pageTitleFollowing => 'Following';

  @override
  String get emptyNoVideosUsingSound => 'No videos using this sound yet';

  @override
  String get emptyNoSoundsAvailable => 'No sounds available';

  @override
  String get emptyNoSoundSearchResults => 'No sounds found';

  @override
  String get emptyNoPhotoLibrary =>
      'No photos or videos found in your library.';

  @override
  String get messagePermissionPhotoLibrary =>
      'Allow photo library access to pick photos and videos.';

  @override
  String get messagePostingStory => 'Posting story...';

  @override
  String get messageProcessingVideo => 'Processing video...';

  @override
  String get messageUploadingVideo => 'Uploading video';

  @override
  String get messageReadyToPost => 'Ready to post';

  @override
  String get messageUploadFailed => 'Upload failed';

  @override
  String messageUploadingPercent(int percent) {
    return 'Uploading $percent%';
  }

  @override
  String get labelOriginalSound => 'Original Audio';

  @override
  String get labelShare => 'Share';

  @override
  String get labelFollow => 'Follow';

  @override
  String get labelFollowing => 'Following';

  @override
  String get labelUnfollow => 'Unfollow';

  @override
  String get labelPosts => 'Posts';

  @override
  String get labelPrivacyPolicy => 'Privacy Policy';

  @override
  String get labelTermsOfService => 'Terms of Service';

  @override
  String get labelSupport => 'Support';

  @override
  String get tooltipBack => 'Back';

  @override
  String get errorFailedToLoadImage => 'Failed to load image';

  @override
  String get pageTitleSignIn => 'Sign In';

  @override
  String get messageEnterHandle =>
      'Enter your Atmosphere Account handle to sign in.';

  @override
  String get pageTitleSignInAgain => 'Sign in again';

  @override
  String get messageSavedSessionRecovery =>
      'We found your saved account, but your session could not be verified. You can sign in again with this handle or go back to get started.';

  @override
  String buttonContinueAs(String handle) {
    return 'Continue as $handle';
  }

  @override
  String get buttonGoToGetStarted => 'Go to get started';

  @override
  String get errorEnterHandle => 'Enter your handle';

  @override
  String errorSignInFailed(String details) {
    return 'Sign in failed: $details';
  }

  @override
  String get messageCompletingSignUp => 'Completing sign up...';

  @override
  String get messageWelcome => 'Welcome!';

  @override
  String get messageWelcomeDescription =>
      'Share videos, connect with friends,\nand take back your timeline.';

  @override
  String get labelReply => 'Reply';

  @override
  String get hintAddImage => 'Add image (1 max)';

  @override
  String get messagePostingImage => 'Posting...';

  @override
  String get messageMaximumImagesReached => 'Maximum images reached';

  @override
  String get labelSound => 'Sound';

  @override
  String get titleSelectSound => 'Select sound';

  @override
  String get hintSearchSounds => 'Search sounds';

  @override
  String get labelStickers => 'Stickers';

  @override
  String get labelPaint => 'Paint';

  @override
  String get labelText => 'Text';

  @override
  String get labelCrop => 'Crop';

  @override
  String get labelTune => 'Tune';

  @override
  String get labelFilter => 'Filter';

  @override
  String get labelBlur => 'Blur';

  @override
  String get labelEmoji => 'Emoji';

  @override
  String get labelMention => 'Mention';

  @override
  String get labelDraw => 'Draw';

  @override
  String get labelMyAwesomeVideo => 'My awesome video';

  @override
  String get errorUploadingVideo => 'Uploading video';

  @override
  String get errorProcessingVideoStatus => 'Processing video';

  @override
  String get errorReadyToPost => 'Ready to post';

  @override
  String get errorUploadFailed => 'Upload failed';

  @override
  String errorSnackBar(String error) {
    return 'Error: $error';
  }

  @override
  String get buttonLikeFeed => 'Like Feed';

  @override
  String get buttonUnlikeFeed => 'Unlike Feed';

  @override
  String get emptyNoNotifications => 'No notifications';

  @override
  String notificationLikedPost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others liked your post',
      one: 'and 1 other liked your post',
      zero: 'liked your post',
    );
    return '$_temp0';
  }

  @override
  String notificationLikedReply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others liked your reply',
      one: 'and 1 other liked your reply',
      zero: 'liked your reply',
    );
    return '$_temp0';
  }

  @override
  String notificationLikedRepost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others liked your repost',
      one: 'and 1 other liked your repost',
      zero: 'liked your repost',
    );
    return '$_temp0';
  }

  @override
  String notificationRepostedPost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others reposted your post',
      one: 'and 1 other reposted your post',
      zero: 'reposted your post',
    );
    return '$_temp0';
  }

  @override
  String notificationRepostedReply(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others reposted your reply',
      one: 'and 1 other reposted your reply',
      zero: 'reposted your reply',
    );
    return '$_temp0';
  }

  @override
  String notificationRepostedRepost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others reposted your repost',
      one: 'and 1 other reposted your repost',
      zero: 'reposted your repost',
    );
    return '$_temp0';
  }

  @override
  String notificationFollowed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'and $count others followed you',
      one: 'and 1 other followed you',
      zero: 'followed you',
    );
    return '$_temp0';
  }

  @override
  String get notificationFollowedBack => 'followed you back';

  @override
  String get notificationMentioned => 'mentioned you';

  @override
  String get notificationRepliedPost => 'replied to your post';

  @override
  String get notificationRepliedReply => 'replied to your reply';

  @override
  String get notificationNotified => 'notified you';

  @override
  String get messageAllCaughtUp => 'You\'re all caught up!';

  @override
  String get messageLabelerConfigDescription =>
      'Configure how this labeler\'s content labels are handled in your feeds.';

  @override
  String get errorLoadingNotifications => 'Failed to load notifications';

  @override
  String get labelContentLabelSettings => 'Content Label Settings';

  @override
  String get errorPhotoSelectLimit =>
      'You can only select photos in multi-select mode.';

  @override
  String errorPhotoSelectMax(int max) {
    return 'You can select up to $max.';
  }

  @override
  String get errorUnableToAccessPhotos =>
      'Unable to access the selected photos.';

  @override
  String get errorUnableToAccessMedia => 'Unable to access this media item.';

  @override
  String get labelSingleSelect => 'Single Select';

  @override
  String get labelSelectMultiple => 'Select multiple';

  @override
  String get labelLibrary => 'Library';

  @override
  String labelDoneCount(int current, int max) {
    return 'Done ($current/$max)';
  }

  @override
  String get messageLimitedLibraryAccess =>
      'Limited library access is enabled. You can change this in settings.';

  @override
  String get tabPosts => 'Posts';

  @override
  String get tabUsers => 'Users';

  @override
  String get hintSearchByHandle => 'Search by handle or display name';

  @override
  String labelFeedByCreator(String handle) {
    return 'by @$handle';
  }

  @override
  String get messagePostsFromFollowing => 'Posts from people you follow';

  @override
  String get buttonAddFeed => 'Add feed';

  @override
  String get buttonUnpinFeed => 'Unpin feed';

  @override
  String get buttonPinFeed => 'Pin feed';

  @override
  String get emptyNoConversations => 'No conversations yet';

  @override
  String get messageSending => 'Sending...';

  @override
  String profileKnownFollowersOne(String name) {
    return 'Followed by $name';
  }

  @override
  String profileKnownFollowersTwo(String firstName, String secondName) {
    return 'Followed by $firstName and $secondName';
  }

  @override
  String profileKnownFollowersOneAndOthers(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count others',
      one: '1 other',
    );
    return 'Followed by $name and $_temp0';
  }

  @override
  String profileKnownFollowersTwoAndOthers(
    String firstName,
    String secondName,
    int count,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count others',
      one: '1 other',
    );
    return 'Followed by $firstName, $secondName, and $_temp0';
  }

  @override
  String get buttonSend => 'Send';
}
