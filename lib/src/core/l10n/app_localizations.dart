import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// Delete option in options panel
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// Block option in options panel
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get buttonBlock;

  /// Unblock option in options panel
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get buttonUnblock;

  /// Report option in options panel
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get buttonReport;

  /// Report Profile option in options panel
  ///
  /// In en, this message translates to:
  /// **'Report Profile'**
  String get buttonReportProfile;

  /// Close option in options panel
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buttonRemove;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get buttonTryAgain;

  /// Go back button text
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get buttonGoBack;

  /// Allow access button for permissions
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get buttonAllowAccess;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get buttonOpenSettings;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get buttonSubmit;

  /// Error message for required fields
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get inputErrorRequired;

  /// Error message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get inputErrorEmail;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Placeholder text for search inputs
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get pageTitleSettings;

  /// Story manager page title
  ///
  /// In en, this message translates to:
  /// **'Story Manager'**
  String get pageTitleStoryManager;

  /// Sound page title
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get pageTitleSound;

  /// Your feeds page title
  ///
  /// In en, this message translates to:
  /// **'Your Feeds'**
  String get pageTitleYourFeeds;

  /// Blocked users page title
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get pageTitleBlockedUsers;

  /// Edit profile page title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get pageTitleEditProfile;

  /// Complete profile page title
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get pageTitleCompleteProfile;

  /// Labeler settings page title
  ///
  /// In en, this message translates to:
  /// **'Labeler Settings'**
  String get pageTitleLabelerSettings;

  /// Labelers page title
  ///
  /// In en, this message translates to:
  /// **'Labelers'**
  String get pageTitleLabelers;

  /// Result page title
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get pageTitleResult;

  /// Delete story dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Story'**
  String get dialogDeleteStory;

  /// Delete story confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this story?'**
  String get dialogDeleteStoryConfirm;

  /// Remove labeler dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Labeler'**
  String get dialogRemoveLabeler;

  /// Remove labeler confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this labeler?'**
  String get dialogRemoveLabelerConfirm;

  /// Remove feed dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Feed'**
  String get dialogRemoveFeed;

  /// Delete post dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get dialogDeletePost;

  /// Delete comment dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get dialogDeleteComment;

  /// Empty state for no users
  ///
  /// In en, this message translates to:
  /// **'No users to display.'**
  String get emptyNoUsers;

  /// Empty state for no blocked users
  ///
  /// In en, this message translates to:
  /// **'No blocked users.'**
  String get emptyNoBlockedUsers;

  /// Empty state for no stories
  ///
  /// In en, this message translates to:
  /// **'No stories'**
  String get emptyNoStories;

  /// Empty state for no comments
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get emptyNoComments;

  /// Empty state for no crosspost comments
  ///
  /// In en, this message translates to:
  /// **'No crosspost comments yet.'**
  String get emptyNoCrosspostComments;

  /// Empty state for no labelers
  ///
  /// In en, this message translates to:
  /// **'No Labelers'**
  String get emptyNoLabelers;

  /// Description for empty labelers state
  ///
  /// In en, this message translates to:
  /// **'Add labelers to customize content moderation'**
  String get emptyNoLabelersDescription;

  /// Empty state for discover content
  ///
  /// In en, this message translates to:
  /// **'Discover new content'**
  String get emptyDiscoverContent;

  /// Empty state for no media
  ///
  /// In en, this message translates to:
  /// **'No photos or videos found...'**
  String get emptyNoMedia;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// Error loading feed message
  ///
  /// In en, this message translates to:
  /// **'Error loading feed'**
  String get errorLoadingFeed;

  /// Error loading sound message
  ///
  /// In en, this message translates to:
  /// **'Error loading sound'**
  String get errorLoadingSound;

  /// Error loading reposts message
  ///
  /// In en, this message translates to:
  /// **'Error loading reposts'**
  String get errorLoadingReposts;

  /// Error loading likes message
  ///
  /// In en, this message translates to:
  /// **'Error loading likes'**
  String get errorLoadingLikes;

  /// Error loading posts message
  ///
  /// In en, this message translates to:
  /// **'Error loading posts'**
  String get errorLoadingPosts;

  /// Search placeholder for users and posts
  ///
  /// In en, this message translates to:
  /// **'Search users, posts...'**
  String get hintSearchUsersPosts;

  /// Search placeholder for users
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get hintSearchUsers;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get hintMessage;

  /// Type message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get hintTypeMessage;

  /// Add description placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a caption... (optional)'**
  String get hintAddDescription;

  /// Add alt text placeholder
  ///
  /// In en, this message translates to:
  /// **'Add alt text'**
  String get hintAddAltText;

  /// Display name input label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get hintDisplayName;

  /// Bio input label
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get hintBio;

  /// DID or handle input label
  ///
  /// In en, this message translates to:
  /// **'DID or Handle'**
  String get hintDidOrHandle;

  /// DID or handle input hint
  ///
  /// In en, this message translates to:
  /// **'did:plc:... or @handle.bsky.social'**
  String get hintDidOrHandleExample;

  /// Additional details input placeholder
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get hintAdditionalDetails;

  /// Image description input label
  ///
  /// In en, this message translates to:
  /// **'Image Description'**
  String get hintImageDescription;

  /// Message to log in
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile'**
  String get messagePleaseLogin;

  /// Message to log in for blocked users
  ///
  /// In en, this message translates to:
  /// **'Please log in to view blocked users'**
  String get messagePleaseLoginBlocked;

  /// Posted time ago message
  ///
  /// In en, this message translates to:
  /// **'Posted {time} ago'**
  String messagePostedAgo(String time);

  /// Show replies message
  ///
  /// In en, this message translates to:
  /// **'Show {count} replies'**
  String messageShowReplies(int count);

  /// Auto delete stories message
  ///
  /// In en, this message translates to:
  /// **'Stories auto-delete after 24 hours'**
  String get messageAutoDeleteStories;

  /// Detailed description for the auto delete stories setting, including the initial cleanup warning
  ///
  /// In en, this message translates to:
  /// **'Stories are public and stored on your PDS indefinitely. Enable this so the app auto deletes them forever after 24h. Enabling this will also execute an initial cleanup of any stories older than 24h.'**
  String get messageAutoDeleteStoriesDescription;

  /// Exporting video progress message
  ///
  /// In en, this message translates to:
  /// **'Exporting video…'**
  String get messageExportingVideo;

  /// Story number label
  ///
  /// In en, this message translates to:
  /// **'Story {number}'**
  String messageStoryNumber(int number);

  /// Manage tooltip
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get tooltipManage;

  /// Delete tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get tooltipDelete;

  /// Retry tooltip
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get tooltipRetry;

  /// Label settings tooltip
  ///
  /// In en, this message translates to:
  /// **'Label settings'**
  String get tooltipLabelSettings;

  /// Remove labeler tooltip
  ///
  /// In en, this message translates to:
  /// **'Remove labeler'**
  String get tooltipRemoveLabeler;

  /// Revert tooltip
  ///
  /// In en, this message translates to:
  /// **'Revert'**
  String get tooltipRevert;

  /// Generation time label
  ///
  /// In en, this message translates to:
  /// **'Generation time:'**
  String get labelGenerationTime;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration:'**
  String get labelDuration;

  /// Size label
  ///
  /// In en, this message translates to:
  /// **'Size:'**
  String get labelSize;

  /// Resolution label
  ///
  /// In en, this message translates to:
  /// **'Resolution:'**
  String get labelResolution;

  /// Add labeler label
  ///
  /// In en, this message translates to:
  /// **'Add Labeler'**
  String get labelAddLabeler;

  /// Character count label
  ///
  /// In en, this message translates to:
  /// **'{count}/1000'**
  String labelCharacters(int count);

  /// Report category: Violence
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get categoryViolence;

  /// Report category: Sexual Content
  ///
  /// In en, this message translates to:
  /// **'Sexual Content'**
  String get categorySexualContent;

  /// Report category: Child Safety
  ///
  /// In en, this message translates to:
  /// **'Child Safety'**
  String get categoryChildSafety;

  /// Report category: Harassment
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get categoryHarassment;

  /// Report category: Misleading
  ///
  /// In en, this message translates to:
  /// **'Misleading'**
  String get categoryMisleading;

  /// Report category: Rule Violations
  ///
  /// In en, this message translates to:
  /// **'Rule Violations'**
  String get categoryRuleViolations;

  /// Report category: Self-Harm
  ///
  /// In en, this message translates to:
  /// **'Self-Harm'**
  String get categorySelfHarm;

  /// Report category: Other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get buttonGetStarted;

  /// Already have an account button text
  ///
  /// In en, this message translates to:
  /// **'I have an Atmosphere Account'**
  String get buttonHaveAccount;

  /// Open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get buttonOpen;

  /// Post button text
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get buttonPost;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get buttonDone;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get buttonShare;

  /// Copied state text for copy link
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get buttonCopied;

  /// Copy link button text
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get buttonCopyLink;

  /// Error message for invalid handle
  ///
  /// In en, this message translates to:
  /// **'Invalid handle'**
  String get errorInvalidHandle;

  /// Error message for handle not found
  ///
  /// In en, this message translates to:
  /// **'Could not find this handle'**
  String get errorHandleNotFound;

  /// Loading message when completing sign in
  ///
  /// In en, this message translates to:
  /// **'Completing sign in...'**
  String get errorCompletingSignIn;

  /// Error message for profile not found
  ///
  /// In en, this message translates to:
  /// **'Profile not found'**
  String get errorProfileNotFound;

  /// Error loading post message
  ///
  /// In en, this message translates to:
  /// **'Error loading post'**
  String get errorLoadingPost;

  /// Error loading messages message
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages'**
  String get errorLoadingMessages;

  /// Error loading conversations message
  ///
  /// In en, this message translates to:
  /// **'Failed to load conversations'**
  String get errorLoadingConversations;

  /// Error message when unable to open a link
  ///
  /// In en, this message translates to:
  /// **'Unable to open link right now.'**
  String get errorUnableToOpenLink;

  /// Error loading labeler settings message
  ///
  /// In en, this message translates to:
  /// **'Error Loading Labeler Settings'**
  String get errorLoadingLabelerSettings;

  /// Error message with detail
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetail(String error);

  /// Add a comment input placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get hintAddComment;

  /// Search users placeholder in messages
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get hintSearchUsersMessages;

  /// Delete comment confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this comment? This action cannot be undone.'**
  String get dialogDeleteCommentConfirm;

  /// Delete post confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post? This action cannot be undone.'**
  String get dialogDeletePostConfirm;

  /// Block user dialog title
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get dialogBlockUser;

  /// Block user confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to block this user? You will no longer see their posts.'**
  String get dialogBlockUserConfirm;

  /// Unblock user dialog title
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get dialogUnblockUser;

  /// Unblock user confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unblock this user?'**
  String get dialogUnblockUserConfirm;

  /// Remove feed confirmation message with name
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{name}\"?'**
  String dialogRemoveFeedConfirm(String name);

  /// Dialog title for opening Bluesky account management
  ///
  /// In en, this message translates to:
  /// **'Open Bluesky account management?'**
  String get dialogOpenBlueskyAccount;

  /// Description for opening Bluesky account management dialog
  ///
  /// In en, this message translates to:
  /// **'This opens the Bluesky account management screen. You may have to log in again.\n\nIf prompted for an account provider, use:\n{pdsUrl}'**
  String dialogOpenBlueskyAccountDescription(String pdsUrl);

  /// Replies page title
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get pageTitleReplies;

  /// Review video page title
  ///
  /// In en, this message translates to:
  /// **'Review Video'**
  String get pageTitleReviewVideo;

  /// Review image post page title
  ///
  /// In en, this message translates to:
  /// **'Review Image Post'**
  String get pageTitleReviewImagePost;

  /// Legal page title
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get pageTitleLegal;

  /// Followers page title
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get pageTitleFollowers;

  /// Following page title
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get pageTitleFollowing;

  /// Empty state for no videos using a sound
  ///
  /// In en, this message translates to:
  /// **'No videos using this sound yet'**
  String get emptyNoVideosUsingSound;

  /// Empty state for no photos in library
  ///
  /// In en, this message translates to:
  /// **'No photos or videos found in your library.'**
  String get emptyNoPhotoLibrary;

  /// Permission message for photo library access
  ///
  /// In en, this message translates to:
  /// **'Allow photo library access to pick photos and videos.'**
  String get messagePermissionPhotoLibrary;

  /// Posting story progress message
  ///
  /// In en, this message translates to:
  /// **'Posting story...'**
  String get messagePostingStory;

  /// Processing video progress message
  ///
  /// In en, this message translates to:
  /// **'Processing video...'**
  String get messageProcessingVideo;

  /// Uploading video status message
  ///
  /// In en, this message translates to:
  /// **'Uploading video'**
  String get messageUploadingVideo;

  /// Ready to post status message
  ///
  /// In en, this message translates to:
  /// **'Ready to post'**
  String get messageReadyToPost;

  /// Upload failed status message
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get messageUploadFailed;

  /// Uploading percentage status message
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String messageUploadingPercent(int percent);

  /// Original sound label
  ///
  /// In en, this message translates to:
  /// **'Original Sound'**
  String get labelOriginalSound;

  /// Share label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get labelShare;

  /// Following label
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get labelFollowing;

  /// Posts label
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get labelPosts;

  /// Privacy policy link label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get labelPrivacyPolicy;

  /// Terms of service link label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get labelTermsOfService;

  /// Support link label
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get labelSupport;

  /// Back tooltip
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// Error message for failed image load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get errorFailedToLoadImage;

  /// Sign in page title
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get pageTitleSignIn;

  /// Message to enter handle for OAuth
  ///
  /// In en, this message translates to:
  /// **'Enter your Atmosphere Account handle to sign in.'**
  String get messageEnterHandle;

  /// Title for auth recovery page when a saved session could not be verified
  ///
  /// In en, this message translates to:
  /// **'Sign in again'**
  String get pageTitleSignInAgain;

  /// Explanation on auth recovery page after saved session verification fails
  ///
  /// In en, this message translates to:
  /// **'We found your saved account, but your session could not be verified. You can sign in again with this handle or go back to get started.'**
  String get messageSavedSessionRecovery;

  /// Button label for continuing OAuth with a prefilled handle
  ///
  /// In en, this message translates to:
  /// **'Continue as {handle}'**
  String buttonContinueAs(String handle);

  /// Button label to leave auth recovery and open the normal get started page
  ///
  /// In en, this message translates to:
  /// **'Go to get started'**
  String get buttonGoToGetStarted;

  /// Validation error when handle field is empty
  ///
  /// In en, this message translates to:
  /// **'Enter your handle'**
  String get errorEnterHandle;

  /// Error message when OAuth sign in fails
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {details}'**
  String errorSignInFailed(String details);

  /// Loading message when completing sign up
  ///
  /// In en, this message translates to:
  /// **'Completing sign up...'**
  String get messageCompletingSignUp;

  /// Welcome message on register page
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get messageWelcome;

  /// Welcome description on register page
  ///
  /// In en, this message translates to:
  /// **'Share videos, connect with friends,\nand take back your timeline.'**
  String get messageWelcomeDescription;

  /// Reply button label
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get labelReply;

  /// Add image tooltip
  ///
  /// In en, this message translates to:
  /// **'Add image (1 max)'**
  String get hintAddImage;

  /// Posting image progress message
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get messagePostingImage;

  /// Maximum images reached tooltip
  ///
  /// In en, this message translates to:
  /// **'Maximum images reached'**
  String get messageMaximumImagesReached;

  /// Sound label for video editor toolbar
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get labelSound;

  /// Stickers label
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get labelStickers;

  /// Paint editor label
  ///
  /// In en, this message translates to:
  /// **'Paint'**
  String get labelPaint;

  /// Text editor label
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get labelText;

  /// Crop editor label
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get labelCrop;

  /// Tune editor label
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get labelTune;

  /// Filter editor label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get labelFilter;

  /// Blur editor label
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get labelBlur;

  /// Emoji editor label
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get labelEmoji;

  /// Mention editor label
  ///
  /// In en, this message translates to:
  /// **'Mention'**
  String get labelMention;

  /// Draw editor label
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get labelDraw;

  /// Default video clip title
  ///
  /// In en, this message translates to:
  /// **'My awesome video'**
  String get labelMyAwesomeVideo;

  /// Video upload status when uploading
  ///
  /// In en, this message translates to:
  /// **'Uploading video'**
  String get errorUploadingVideo;

  /// Video processing status
  ///
  /// In en, this message translates to:
  /// **'Processing video'**
  String get errorProcessingVideoStatus;

  /// Ready to post status
  ///
  /// In en, this message translates to:
  /// **'Ready to post'**
  String get errorReadyToPost;

  /// Upload failed status
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get errorUploadFailed;

  /// Error message in snackbar
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorSnackBar(String error);

  /// Like feed button text
  ///
  /// In en, this message translates to:
  /// **'Like Feed'**
  String get buttonLikeFeed;

  /// Unlike feed button text
  ///
  /// In en, this message translates to:
  /// **'Unlike Feed'**
  String get buttonUnlikeFeed;

  /// Empty state for no notifications
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get emptyNoNotifications;

  /// Message when all notifications are read
  ///
  /// In en, this message translates to:
  /// **'You\'\'re all caught up!'**
  String get messageAllCaughtUp;

  /// Description for labeler configuration
  ///
  /// In en, this message translates to:
  /// **'Configure how this labeler\'\'s content labels are handled in your feeds.'**
  String get messageLabelerConfigDescription;

  /// Error loading notifications message
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get errorLoadingNotifications;

  /// Content label settings title
  ///
  /// In en, this message translates to:
  /// **'Content Label Settings'**
  String get labelContentLabelSettings;

  /// Error when trying to select photos in single-select mode
  ///
  /// In en, this message translates to:
  /// **'You can only select photos in multi-select mode.'**
  String get errorPhotoSelectLimit;

  /// Error when exceeding max photo selection
  ///
  /// In en, this message translates to:
  /// **'You can select up to {max}.'**
  String errorPhotoSelectMax(int max);

  /// Error when unable to access selected photos
  ///
  /// In en, this message translates to:
  /// **'Unable to access the selected photos.'**
  String get errorUnableToAccessPhotos;

  /// Error when unable to access a media item
  ///
  /// In en, this message translates to:
  /// **'Unable to access this media item.'**
  String get errorUnableToAccessMedia;

  /// Single select mode label
  ///
  /// In en, this message translates to:
  /// **'Single Select'**
  String get labelSingleSelect;

  /// Select multiple mode label
  ///
  /// In en, this message translates to:
  /// **'Select multiple'**
  String get labelSelectMultiple;

  /// Library header label
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get labelLibrary;

  /// Done button with selection count
  ///
  /// In en, this message translates to:
  /// **'Done ({current}/{max})'**
  String labelDoneCount(int current, int max);

  /// Permission info about limited library access
  ///
  /// In en, this message translates to:
  /// **'Limited library access is enabled. You can change this in settings.'**
  String get messageLimitedLibraryAccess;

  /// Posts search tab label
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get tabPosts;

  /// Users search tab label
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get tabUsers;

  /// Search by handle or display name placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by handle or display name'**
  String get hintSearchByHandle;

  /// Feed creator attribution label
  ///
  /// In en, this message translates to:
  /// **'by @{handle}'**
  String labelFeedByCreator(String handle);

  /// Subtitle for following/timeline feed
  ///
  /// In en, this message translates to:
  /// **'Posts from people you follow'**
  String get messagePostsFromFollowing;

  /// Add feed button text
  ///
  /// In en, this message translates to:
  /// **'Add feed'**
  String get buttonAddFeed;

  /// Unpin feed button text
  ///
  /// In en, this message translates to:
  /// **'Unpin feed'**
  String get buttonUnpinFeed;

  /// Pin feed button text
  ///
  /// In en, this message translates to:
  /// **'Pin feed'**
  String get buttonPinFeed;

  /// Empty state for no conversations in share panel
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get emptyNoConversations;

  /// Sending message progress indicator
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get messageSending;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get buttonSend;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
