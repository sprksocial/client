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
  String get errorLoadingSound => 'Error loading sound';

  @override
  String get errorLoadingReposts => 'Error loading reposts';

  @override
  String get errorLoadingLikes => 'Error loading likes';

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
  String get hintAddDescription => 'Add a description... (optional)';

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
}
