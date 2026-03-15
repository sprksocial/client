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
  /// **'Add a description... (optional)'**
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
