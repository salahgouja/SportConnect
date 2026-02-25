import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get navRides;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications for important updates'**
  String get settingsPushNotificationsDesc;

  /// No description provided for @settingsRideReminders.
  ///
  /// In en, this message translates to:
  /// **'Ride Reminders'**
  String get settingsRideReminders;

  /// No description provided for @settingsRideRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Get reminded about upcoming rides'**
  String get settingsRideRemindersDesc;

  /// No description provided for @settingsChatMessages.
  ///
  /// In en, this message translates to:
  /// **'Chat Messages'**
  String get settingsChatMessages;

  /// No description provided for @settingsChatMessagesDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications for new messages'**
  String get settingsChatMessagesDesc;

  /// No description provided for @settingsMarketingTips.
  ///
  /// In en, this message translates to:
  /// **'Marketing & Tips'**
  String get settingsMarketingTips;

  /// No description provided for @settingsMarketingTipsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive tips and promotional offers'**
  String get settingsMarketingTipsDesc;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get settingsDarkModeDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDesc.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get settingsLanguageDesc;

  /// No description provided for @settingsDistanceUnit.
  ///
  /// In en, this message translates to:
  /// **'Distance Unit'**
  String get settingsDistanceUnit;

  /// No description provided for @settingsDistanceUnitDesc.
  ///
  /// In en, this message translates to:
  /// **'Preferred distance measurement'**
  String get settingsDistanceUnitDesc;

  /// No description provided for @settingsPrivacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Safety'**
  String get settingsPrivacySafety;

  /// No description provided for @settingsPublicProfile.
  ///
  /// In en, this message translates to:
  /// **'Public Profile'**
  String get settingsPublicProfile;

  /// No description provided for @settingsPublicProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow others to see your profile'**
  String get settingsPublicProfileDesc;

  /// No description provided for @settingsShowLocation.
  ///
  /// In en, this message translates to:
  /// **'Show Location'**
  String get settingsShowLocation;

  /// No description provided for @settingsShowLocationDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your live location during rides'**
  String get settingsShowLocationDesc;

  /// No description provided for @settingsAutoAcceptRides.
  ///
  /// In en, this message translates to:
  /// **'Auto-Accept Rides'**
  String get settingsAutoAcceptRides;

  /// No description provided for @settingsAutoAcceptRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically accept ride requests'**
  String get settingsAutoAcceptRidesDesc;

  /// No description provided for @settingsBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get settingsBlockedUsers;

  /// No description provided for @settingsBlockedUsersDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage blocked users'**
  String get settingsBlockedUsersDesc;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settingsEditProfile;

  /// No description provided for @settingsEditProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your profile information'**
  String get settingsEditProfileDesc;

  /// No description provided for @settingsPaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get settingsPaymentMethods;

  /// No description provided for @settingsPaymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your payment options'**
  String get settingsPaymentMethodsDesc;

  /// No description provided for @settingsVerifyAccount.
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get settingsVerifyAccount;

  /// No description provided for @settingsVerifyAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete identity verification'**
  String get settingsVerifyAccountDesc;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get settingsSupport;

  /// No description provided for @settingsHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get settingsHelpCenter;

  /// No description provided for @settingsHelpCenterDesc.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get settingsHelpCenterDesc;

  /// No description provided for @settingsReportProblem.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get settingsReportProblem;

  /// No description provided for @settingsReportProblemDesc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs or issues'**
  String get settingsReportProblemDesc;

  /// No description provided for @settingsTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settingsTermsConditions;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get settingsAboutDesc;

  /// No description provided for @settingsDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get settingsDangerZone;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get settingsLogoutDesc;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and data'**
  String get settingsDeleteAccountDesc;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authConfirmPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// No description provided for @authContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// No description provided for @authContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueWithApple;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get actionConfirm;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get actionFilter;

  /// No description provided for @actionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get actionApply;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input. Please check your entry.'**
  String get errorInvalidInput;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get errorPermissionDenied;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get errorUnexpected;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get errorTimeout;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Text from Text in app_router.dart
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// Text from Text in app_router.dart
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// Text from Text in feature_discovery_service.dart
  ///
  /// In en, this message translates to:
  /// **'Step {value1} of {value2}'**
  String stepValueOfValue(Object value1, Object value2);

  /// Text from Text in feature_discovery_service.dart
  ///
  /// In en, this message translates to:
  /// **'Skip tour'**
  String get skipTour;

  /// Text from _buildMenuButton.label in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// Text from _buildMenuButton.label in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme Playground'**
  String get themePlayground;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Color Scheme'**
  String get colorScheme;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Surface Blend: {value}%'**
  String surfaceBlendValue(Object value);

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Use Material 3'**
  String get useMaterial3;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Component Preview'**
  String get componentPreview;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get elevated;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get filled;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Outlined'**
  String get outlined;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// Text from InputDecoration.labelText in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Text Field'**
  String get textField;

  /// Text from InputDecoration.hintText in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Enter text...'**
  String get enterText;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Card Title'**
  String get cardTitle;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Card subtitle with description'**
  String get cardSubtitleWithDescription;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Chip 1'**
  String get chip1;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// Text from _buildSection.title in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Color Palette'**
  String get colorPalette;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get secondary;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Surface'**
  String get surface;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// Text from _buildColorChip in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Copy Theme Code'**
  String get copyThemeCode;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Apply Theme'**
  String get applyTheme;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme code copied to logs!'**
  String get themeCodeCopiedToLogs;

  /// Text from Text in debug_overlay.dart
  ///
  /// In en, this message translates to:
  /// **'Theme \"{value}\" applied!'**
  String themeValueApplied(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'LVL {value}'**
  String lvlValue(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} / {value2} XP'**
  String valueValueXp(Object value1, Object value2);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String value(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value}'**
  String value2(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'#{value}'**
  String value3(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} XP'**
  String valueXp(Object value);

  /// Text from Text in gamification_widgets.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2}'**
  String valueValue(Object value1, Object value2);

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'standard'**
  String get standard;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard2;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'terrain'**
  String get terrain;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Terrain'**
  String get terrain2;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get dark;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get light;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'humanitarian'**
  String get humanitarian;

  /// Text from _buildMapStyleItem in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Humanitarian'**
  String get humanitarian2;

  /// Text from InputDecoration.hintText in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Search address, city, or place...'**
  String get searchAddressCityOrPlace;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Popular Cities'**
  String get popularCities;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Selected Location'**
  String get selectedLocation;

  /// Text from Text in map_location_picker.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get confirmLocation;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Nearby Places'**
  String get nearbyPlaces;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Find useful spots along your route'**
  String get findUsefulSpotsAlongYour;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Search Radius'**
  String get searchRadius;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Select a category to search'**
  String get selectACategoryToSearch;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Tap on any category above to find nearby places'**
  String get tapOnAnyCategoryAbove;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Text from Text in poi_search_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'Try increasing the search radius'**
  String get tryIncreasingTheSearchRadius;

  /// Text from Text in premium_avatar.dart
  ///
  /// In en, this message translates to:
  /// **'Lv.{value}'**
  String lvValue(Object value);

  /// Text from Text in premium_avatar.dart
  ///
  /// In en, this message translates to:
  /// **'+{value}'**
  String value4(Object value);

  /// Text from Text in premium_navigation.dart
  ///
  /// In en, this message translates to:
  /// **'99+'**
  String get text99;

  /// Text from Text in premium_navigation.dart
  ///
  /// In en, this message translates to:
  /// **'9+'**
  String get text9;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} rides • {value2}'**
  String valueRidesValue(Object value1, Object value2);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} €'**
  String value5(Object value);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} seats left'**
  String valueSeatsLeft(Object value);

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'Fully booked'**
  String get fullyBooked;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Text from Text in premium_ride_card.dart
  ///
  /// In en, this message translates to:
  /// **'{value} seats'**
  String valueSeats(Object value);

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error saving vehicle: {value}'**
  String errorSavingVehicleValue(Object value);

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Setup'**
  String get driverSetup;

  /// Text from _buildStepIndicator in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Text from _buildStepIndicator in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payouts'**
  String get payouts;

  /// Text from _buildStepHeader.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Your Vehicle'**
  String get addYourVehicle;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get fuelType;

  /// Text from _buildStepHeader.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Setup Payouts'**
  String get setupPayouts;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure Payments'**
  String get securePayments;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fast Transfers'**
  String get fastTransfers;

  /// Text from _buildBenefitItem.title in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Easy Tracking'**
  String get easyTracking;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip for now, I\'ll set this up later'**
  String get skipForNowILl;

  /// Text from Text in driver_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You can still offer rides without setting up payouts, but you won\'t be able to receive payments until you complete this step.'**
  String get youCanStillOfferRides;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect'**
  String get sportconnect;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your running journey'**
  String get signInToContinueYour;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get donTHaveAnAccount;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you instructions to reset your password.'**
  String get enterYourEmailAddressAnd;

  /// Text from Text in login_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get passwordResetEmailSentCheck;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get pleaseAgreeToTheTerms;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Join our community of eco-friendly riders'**
  String get joinOurCommunityOfEco;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Welcome Bonus'**
  String get welcomeBonus;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get 100 XP when you complete your profile!'**
  String get get100XpWhenYou;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I want to:'**
  String get iWantTo;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find rides'**
  String get findRides;

  /// Text from Text in register_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer rides'**
  String get offerRides;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please select a role to continue'**
  String get pleaseSelectARoleTo;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {value}'**
  String errorValue(Object value);

  /// Text from _buildRoleCard.title in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I\'m a Rider'**
  String get iMARider;

  /// Text from _buildRoleCard.title in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'I\'m a Driver'**
  String get iMADriver;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You can change your role later in settings'**
  String get youCanChangeYourRole;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How will you use SportConnect?'**
  String get howWillYouUseSportconnect;

  /// Text from Text in role_selection_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Choose your role to get started.\nThis will customize your experience.'**
  String get chooseYourRoleToGet;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🎉'**
  String get text2;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Join 10,000+ eco-riders'**
  String get join10000EcoRiders;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get 100 XP welcome bonus!'**
  String get get100XpWelcomeBonus;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Or sign up with'**
  String get orSignUpWith;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Strong Password Tips'**
  String get strongPasswordTips;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Use 8+ characters with letters, numbers & symbols'**
  String get use8CharactersWithLetters;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password Strength'**
  String get passwordStrength;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Interests (Optional)'**
  String get yourInterestsOptional;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select sports you\'re interested in'**
  String get selectSportsYouReInterested;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a Profile Photo'**
  String get addAProfilePhoto;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This helps others recognize you'**
  String get thisHelpsOthersRecognizeYou;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ready to Join!'**
  String get readyToJoin;

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Email: {value}'**
  String emailValue(Object value);

  /// Text from Text in signup_wizard_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Role: {value}'**
  String roleValue(Object value);

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'CARPOOLING FOR RUNNERS'**
  String get carpoolingForRunners;

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share rides. Run together.\nGo further.'**
  String get shareRidesRunTogetherGo;

  /// Text from Text in splash_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer Ride'**
  String get offerRide;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accepting ride requests'**
  String get acceptingRideRequests;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to go online and start earning'**
  String get tapToGoOnlineAnd;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load status'**
  String get failedToLoadStatus;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaySEarnings;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get live;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€{value}'**
  String value6(Object value);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} rides'**
  String valueRides(Object value);

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load earnings'**
  String get failedToLoadEarnings;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Requests'**
  String get rideRequests;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Text from _buildEmptyState.title in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get noPendingRequests;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load requests'**
  String get failedToLoadRequests;

  /// Empty state title for accepted requests tab
  ///
  /// In en, this message translates to:
  /// **'No accepted requests yet'**
  String get noAcceptedRequestsYet;

  /// Empty state subtitle for accepted requests tab
  ///
  /// In en, this message translates to:
  /// **'Accepted ride requests will appear here'**
  String get acceptedRequestsWillAppearHere;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Upcoming Rides'**
  String get upcomingRides;

  /// Text from _buildEmptyState.title in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No upcoming rides'**
  String get noUpcomingRides;

  /// Text from _buildErrorCard in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load rides'**
  String get failedToLoadRides;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get kNew;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2}'**
  String valueSeatValue(Object value1, Object value2);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} → {value2}'**
  String valueValue2(Object value1, Object value2);

  /// Text from Text in driver_home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'earned'**
  String get earned;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get loadingRoute;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String valueKm(Object value);

  /// Text from _buildStatItem in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'rides'**
  String get rides;

  /// Text from _buildStatItem in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get seats;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Hotspots'**
  String get hotspots;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Nearby Rides'**
  String get nearbyRides;

  /// Text from _buildMapControl.tooltip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Follow Location'**
  String get followLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String valueMin(Object value);

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get mapStyle;

  /// Text from _buildStyleOption in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark2;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find a Ride'**
  String get findARide;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Text from InputDecoration.hintText in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'From where?'**
  String get fromWhere;

  /// Text from InputDecoration.hintText in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'To where?'**
  String get toWhere;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} available'**
  String valueAvailable(Object value);

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No rides available nearby'**
  String get noRidesAvailableNearby;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try expanding your search radius'**
  String get tryExpandingYourSearchRadius;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup point'**
  String get pickupPoint;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Text from _buildSearchChip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get eco;

  /// Text from _buildSearchChip in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocation;

  /// Text from Text in home_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Book This Ride'**
  String get bookThisRide;

  /// Text from _buildStatItem in quick_stats_card.dart
  ///
  /// In en, this message translates to:
  /// **'ride'**
  String get ride;

  /// Text from _buildStatItem in quick_stats_card.dart
  ///
  /// In en, this message translates to:
  /// **'seat'**
  String get seat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sending image...'**
  String get sendingImage;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to send image: {value}'**
  String failedToSendImageValue(Object value);

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to start call: {value}'**
  String failedToStartCallValue(Object value);

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search in Chat'**
  String get searchInChat;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mute Notifications'**
  String get muteNotifications;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notifications muted for this chat'**
  String get notificationsMutedForThisChat;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all messages? This action cannot be undone.'**
  String get areYouSureYouWant;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Chat cleared'**
  String get chatCleared;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesYet;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Send a message to start the conversation'**
  String get sendAMessageToStart;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'typing...'**
  String get typing;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Replying to {value}'**
  String replyingToValue(Object value);

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to open map'**
  String get tapToOpenMap;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get thisMessageWasDeleted;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get edited;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// Text from _buildOptionItem in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get messageCopied;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Message'**
  String get editMessage;

  /// Text from InputDecoration.hintText in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// Text from _buildAttachmentOption in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingYourLocation;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Location shared'**
  String get locationShared;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Coordinates copied to clipboard'**
  String get coordinatesCopiedToClipboard;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open maps: {value}'**
  String couldNotOpenMapsValue(Object value);

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recording... Release to send'**
  String get recordingReleaseToSend;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get voiceNote;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Voice notes coming soon! Use text for now.'**
  String get voiceNotesComingSoonUse;

  /// Text from Text in chat_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recording cancelled'**
  String get recordingCancelled;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please login to view chats'**
  String get pleaseLoginToViewChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No group chats'**
  String get noGroupChats;

  /// Text from _buildEmptyState.title in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No ride chats'**
  String get noRideChats;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get callHistory;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No call history'**
  String get noCallHistory;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCall;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCall;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **' • '**
  String get text3;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// Text from InputDecoration.hintText in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search users by name...'**
  String get searchUsersByName;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search for a user to start chatting'**
  String get searchForAUserTo;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters'**
  String get typeAtLeast2Characters;

  /// Text from Text in chat_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{value}\"'**
  String noUsersFoundForValue(Object value);

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsMarkedAsRead;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all notifications?'**
  String get areYouSureYouWant2;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get allNotificationsCleared;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to clear notifications'**
  String get failedToClearNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view notifications'**
  String get pleaseSignInToView;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} new'**
  String valueNew(Object value);

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll2;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get youReAllCaughtUp;

  /// Text from Text in notifications_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open chat: {value}'**
  String couldNotOpenChatValue(Object value);

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'re Ready to Run'**
  String get youReReadyToRun;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Create an account to start tracking your runs and connect with other runners.'**
  String get createAnAccountToStart;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get kContinue;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Text from Text in onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This week: {value} €'**
  String thisWeekValue(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings Overview'**
  String get earningsOverview;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Text from _buildEarningsBreakdownItem in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rides Earnings'**
  String get ridesEarnings;

  /// Text from _buildEarningsBreakdownItem in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tips & Bonuses'**
  String get tipsBonuses;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Environmental Impact'**
  String get environmentalImpact;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg CO₂ saved'**
  String valueKgCoSaved(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Stripe Connected'**
  String get stripeConnected;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Up Payouts'**
  String get setUpPayouts;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Receive payments from riders'**
  String get receivePaymentsFromRiders;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete Verification'**
  String get completeVerification;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account'**
  String get connectYourBankAccount;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get availableBalance;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Payout'**
  String get confirmPayout;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Withdraw {value} € to your connected bank account?'**
  String withdrawValueToYourConnected(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout of {value} € initiated!'**
  String payoutOfValueInitiated(Object value);

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout failed. Please try again.'**
  String get payoutFailedPleaseTryAgain;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get failedToLoadTransactions;

  /// Text from Text in driver_earnings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}{value2} €'**
  String valueValue3(Object value1, Object value2);

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Get Paid for Your Rides'**
  String get getPaidForYourRides;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect your bank account to receive payments directly from riders. Powered by Stripe for secure transactions.'**
  String get connectYourBankAccountTo;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Instant Payouts'**
  String get instantPayouts;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure & Protected'**
  String get secureProtected;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Clear Tracking'**
  String get clearTracking;

  /// Text from _buildBenefitItem.title in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Low Fees'**
  String get lowFees;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You\'ll be redirected to Stripe to complete setup'**
  String get youLlBeRedirectedTo;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe'**
  String get connectStripe;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Stripe account connected successfully!'**
  String get stripeAccountConnectedSuccessfully;

  /// Text from Text in driver_stripe_onboarding_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading page: {value}'**
  String errorLoadingPageValue(Object value);

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to view payment history'**
  String get pleaseSignInToView2;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Transactions'**
  String get yourTransactions;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPaymentsFound;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your payment history will appear here'**
  String get yourPaymentHistoryWillAppear;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Payment'**
  String get ridePayment;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} {value2}'**
  String valueValue4(Object value1, Object value2);

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get seats2;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Platform Fee'**
  String get platformFee;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'•••• {value}'**
  String value7(Object value);

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Text from _buildDetailRow in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// Text from Text in payment_history_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request Refund'**
  String get requestRefund;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading achievements'**
  String get errorLoadingAchievements;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Level {value1} - {value2}'**
  String levelValueValue(Object value1, Object value2);

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} XP'**
  String valueXp2(Object value);

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} XP to Level {value2}'**
  String valueXpToLevelValue(Object value1, Object value2);

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🏆'**
  String get text4;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🎯'**
  String get text5;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🚗'**
  String get text6;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🌍'**
  String get text7;

  /// Text from _buildStatItem in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'kg CO₂'**
  String get kgCo;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'✓ Unlocked'**
  String get unlocked;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🔒 Locked'**
  String get locked;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}% Complete'**
  String valueComplete(Object value);

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥈'**
  String get text8;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mike C.'**
  String get mikeC;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'11.2K'**
  String get text112k;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥇'**
  String get text10;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sarah J.'**
  String get sarahJ;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'12.4K'**
  String get text124k;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'🥉'**
  String get text11;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Emily D.'**
  String get emilyD;

  /// Text from _buildTopRanker in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'9.8K'**
  String get text98k;

  /// Text from Text in achievements_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Level {value}'**
  String levelValue(Object value);

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified Driver'**
  String get verifiedDriver;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'...'**
  String get text12;

  /// Text from _buildQuickStat in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0.0'**
  String get text00;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Trips'**
  String get totalTrips;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} this month'**
  String valueThisMonth(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} € this month'**
  String valueThisMonth2(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'CO₂ Saved'**
  String get coSaved;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String valueKg(Object value);

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Since joining'**
  String get sinceJoining;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get avgRating;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Last 100 trips'**
  String get last100Trips;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0 €'**
  String get text0;

  /// Text from _buildStatCard in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get text0Kg;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating Breakdown'**
  String get ratingBreakdown;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trips this week'**
  String get tripsThisWeek;

  /// Text from Text in driver_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} trips'**
  String valueTrips(Object value);

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Settings'**
  String get driverSettings;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Preferences'**
  String get ridePreferences;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Auto-Accept Requests'**
  String get autoAcceptRequests;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Automatically accept ride requests that match your criteria'**
  String get automaticallyAcceptRideRequestsThat;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Instant Booking'**
  String get allowInstantBooking;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Let passengers book without waiting for approval'**
  String get letPassengersBookWithoutWaiting;

  /// Text from _buildSliderTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Maximum Pickup Distance'**
  String get maximumPickupDistance;

  /// Text from _buildSliderTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Only receive requests within this distance'**
  String get onlyReceiveRequestsWithinThis;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Settings'**
  String get paymentSettings;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Cash Payments'**
  String get acceptCashPayments;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to pay with cash'**
  String get allowPassengersToPayWith;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Card Payments'**
  String get acceptCardPayments;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to pay with card in-app'**
  String get allowPassengersToPayWith2;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payout Method'**
  String get payoutMethod;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Bank Account ending in 4532'**
  String get bankAccountEndingIn4532;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tax Documents'**
  String get taxDocuments;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View and download tax forms'**
  String get viewAndDownloadTaxForms;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Navigation & Map'**
  String get navigationMap;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Show on Driver Map'**
  String get showOnDriverMap;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow passengers to see your location'**
  String get allowPassengersToSeeYour;

  /// Text from _buildDropdownTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Preferred Navigation App'**
  String get preferredNavigationApp;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Play sounds for new requests and messages'**
  String get playSoundsForNewRequests;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vibrate for important alerts'**
  String get vibrateForImportantAlerts;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Customize what notifications you receive'**
  String get customizeWhatNotificationsYouReceive;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get nightMode;

  /// Text from _buildSwitchTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reduce eye strain in low light'**
  String get reduceEyeStrainInLow;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account & Security'**
  String get accountSecurity;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Documents'**
  String get driverDocuments;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'License, insurance, and registration'**
  String get licenseInsuranceAndRegistration;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Background Check'**
  String get backgroundCheck;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View your verification status'**
  String get viewYourVerificationStatus;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateYourAccountPassword;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFactorAuthentication;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add extra security to your account'**
  String get addExtraSecurityToYour;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Help Center'**
  String get driverHelpCenter;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'FAQs and troubleshooting guides'**
  String get faqsAndTroubleshootingGuides;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Chat with our support team'**
  String get chatWithOurSupportTeam;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Report a Safety Issue'**
  String get reportASafetyIssue;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Report incidents or concerns'**
  String get reportIncidentsOrConcerns;

  /// Text from _buildSectionHeader in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get accountActions;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Switch to Rider Mode'**
  String get switchToRiderMode;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Use the app as a passenger'**
  String get useTheAppAsA;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Log out of your account'**
  String get logOutOfYourAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pause Driver Account'**
  String get pauseDriverAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Temporarily stop receiving requests'**
  String get temporarilyStopReceivingRequests;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Driver Account'**
  String get deleteDriverAccount;

  /// Text from _buildNavigationTile in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your driver profile'**
  String get permanentlyRemoveYourDriverProfile;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect Driver'**
  String get sportconnectDriver;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Version 2.1.0'**
  String get version210;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get areYouSureYouWant3;

  /// Text from Text in driver_settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your driver data, earnings history, and ratings will be permanently deleted.'**
  String get thisActionCannotBeUndone;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please sign in to manage vehicles'**
  String get pleaseSignInToManage;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Vehicles Added'**
  String get noVehiclesAdded;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add your first vehicle to start\noffering rides'**
  String get addYourFirstVehicleTo;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle set as active'**
  String get vehicleSetAsActive;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {value}?'**
  String areYouSureYouWant4(Object value);

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle deleted'**
  String get vehicleDeleted;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Active'**
  String get setActive;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get make;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Text from _buildTextField.label in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'License Plate'**
  String get licensePlate;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passenger Capacity'**
  String get passengerCapacity;

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} passengers'**
  String valuePassengers(Object value);

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total Rides'**
  String get totalRides;

  /// Text from _buildDetailRow in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} ⭐'**
  String value8(Object value);

  /// Text from Text in driver_vehicle_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'About You'**
  String get aboutYou;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get demographics;

  /// Text from _buildActionTile.label in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Text from _buildActionTile.label in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// Text from _buildSectionLabel in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sports Interests'**
  String get sportsInterests;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get add;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No interests selected'**
  String get noInterestsSelected;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Sports Interests'**
  String get selectSportsInterests;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes.'**
  String get youHaveUnsavedChanges;

  /// Text from Text in edit_profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again'**
  String get pleaseCheckYourConnectionAnd;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Member since {value}'**
  String memberSinceValue(Object value);

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New member'**
  String get newMember;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified Info'**
  String get verifiedInfo;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get notVerified;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Statistics'**
  String get rideStatistics;

  /// Text from _buildStatCard.label in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Text from _buildStatCard.label in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get earned2;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile Not Found'**
  String get profileNotFound;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your profile data could not be loaded.\nThis may happen if you\'re a new user.'**
  String get yourProfileDataCouldNot;

  /// Text from Text in profile_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign out & try again'**
  String get signOutTryAgain;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find People'**
  String get findPeople;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchByName;

  /// Text from InputDecoration.hintText in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find Fellow Riders'**
  String get findFellowRiders;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search for users by their name\nto connect and share rides'**
  String get searchForUsersByTheir;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get noResultsFound2;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No users found matching \"{value}\"'**
  String noUsersFoundMatchingValue(Object value);

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryADifferentSearchTerm;

  /// Text from Text in profile_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Text from _buildNavigationTile.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehicles;

  /// Text from _buildSectionHeader in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'SportConnect v1.0.0'**
  String get sportconnectV100;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Blocked Users'**
  String get noBlockedUsers;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Users you block will appear here'**
  String get usersYouBlockWillAppear;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment integration will be available soon'**
  String get paymentIntegrationWillBeAvailable;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Text from InputDecoration.labelText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get passwordUpdatedSuccessfully;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get gettingStarted;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rides & Carpooling'**
  String get ridesCarpooling;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Safety & Trust'**
  String get safetyTrust;

  /// Text from _buildHelpSection in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountSettings;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Opening: {value}'**
  String openingValue(Object value);

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help! Choose how you\'d like to reach us.'**
  String get weReHereToHelp;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Could not open email app'**
  String get couldNotOpenEmailApp;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get liveChat;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Live chat will be available soon!'**
  String get liveChatWillBeAvailable;

  /// Text from _buildContactOption.title in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Phone Support'**
  String get phoneSupport;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get describeTheProblem;

  /// Text from InputDecoration.hintText in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please describe what happened...'**
  String get pleaseDescribeWhatHappened;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your report has been submitted.'**
  String get thankYouYourReportHas;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of SportConnect?'**
  String get areYouSureYouWant5;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All your data, including:'**
  String get thisActionCannotBeUndone2;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride history and bookings'**
  String get rideHistoryAndBookings;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Profile and achievements'**
  String get profileAndAchievements;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Messages and connections'**
  String get messagesAndConnections;

  /// Text from _buildDeleteWarningItem in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment information'**
  String get paymentInformation;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm:'**
  String get typeDeleteToConfirm;

  /// Text from Text in settings_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {value}'**
  String failedToDeleteAccountValue(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add Ride'**
  String get addRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading vehicles'**
  String get errorLoadingVehicles;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Garage'**
  String get myGarage;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} Vehicles'**
  String valueVehicles(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Set Default'**
  String get setDefault;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Text from _buildMiniInfo in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Garage is Empty'**
  String get garageIsEmpty;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start your journey. Connect with others and share rides.'**
  String get addAVehicleToStart;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Quick Tip'**
  String get quickTip;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Swipe right on a vehicle card to set it as default. Swipe left to remove it.'**
  String get swipeRightOnAVehicle;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Delete Ride?'**
  String get deleteRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {value}? This cannot be undone.'**
  String areYouSureYouWant6(Object value);

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Keep It'**
  String get keepIt;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle removed from garage'**
  String get vehicleRemovedFromGarage;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit Ride'**
  String get editRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New Ride'**
  String get newRide;

  /// Text from Text in vehicles_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats Capacity'**
  String get seatsCapacity;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}\'s Reviews'**
  String valueSReviews(Object value);

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get noReviewsYet;

  /// Error text when reviews fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load reviews'**
  String get failedToLoadReviews;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} reviews'**
  String valueReviews(Object value);

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rider'**
  String get rider;

  /// Text from Text in reviews_list_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get response;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Leave a Review'**
  String get leaveAReview;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'What stood out?'**
  String get whatStoodOut;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Additional comments (optional)'**
  String get additionalCommentsOptional;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Driver'**
  String get yourDriver;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Passenger'**
  String get yourPassenger;

  /// Text from InputDecoration.hintText in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share your experience...'**
  String get shareYourExperience;

  /// Text from Text in submit_review_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Thank you for your review!'**
  String get thankYouForYourReview;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}{value2}'**
  String valueValue5(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading ride'**
  String get errorLoadingRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Tooltip for showing the password in a text field
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get tooltipShowPassword;

  /// Tooltip for hiding the password in a text field
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get tooltipHidePassword;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active Ride'**
  String get activeRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No active ride'**
  String get noActiveRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start a ride to see navigation'**
  String get startARideToSee;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Heading to pickup'**
  String get headingToPickup;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Heading to destination'**
  String get headingToDestination;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'ETA: {value1} min • {value2} km remaining'**
  String etaValueMinValueKm(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Arriving at {value}'**
  String arrivingAtValue(Object value);

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Text from _buildTripStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get fare;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get text5Min;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+{value} more'**
  String valueMore(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} passenger{value2}'**
  String valuePassengerValue(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value1} seat{value2} booked'**
  String valueSeatValueBooked(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2} booked'**
  String valueSeatValueBooked2(Object value1, Object value2);

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€/seat'**
  String get seat2;

  /// Text from _buildPassengerStat in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// Text from _buildLocationRow in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// Text from _buildLocationRow in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoff;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} passenger{value2} booked for this ride'**
  String valuePassengerValueBookedFor(Object value1, Object value2);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride?'**
  String get cancelRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? This may affect your driver rating.'**
  String get areYouSureYouWant7;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Continue Ride'**
  String get continueRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Ride'**
  String get cancelRide2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Manage your rides & earnings'**
  String get manageYourRidesEarnings;

  /// Text from _buildTabWithBadge in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// Text from _buildEarningStat.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'NEW REQUEST'**
  String get newRequest;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tap to respond'**
  String get tapToRespond;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'+€{value}'**
  String value9(Object value);

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'earnings'**
  String get earnings2;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} • {value2}'**
  String valueValue6(Object value1, Object value2);

  /// Text from _buildErrorState in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load user'**
  String get failedToLoadUser;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Active Rides'**
  String get noActiveRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'RIDE IN PROGRESS'**
  String get rideInProgress;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2} passengers'**
  String valueValuePassengers(Object value1, Object value2);

  /// Text from _buildActionChip.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// Text from _buildActionChip.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Scheduled Rides'**
  String get noScheduledRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'€{value}/seat'**
  String valueSeat(Object value);

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Completed Rides'**
  String get noCompletedRides;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} • {value2} passengers'**
  String valueValuePassengers2(Object value1, Object value2);

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading your rides...'**
  String get loadingYourRides;

  /// Text from _buildEmptyState.title in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sign In Required'**
  String get signInRequired;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking accepted!'**
  String get bookingAccepted;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking declined'**
  String get bookingDeclined;

  /// Text from Text in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride completed! Well done 🎉'**
  String get rideCompletedWellDone;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Manage Vehicles'**
  String get manageVehicles;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earnings History'**
  String get earningsHistory;

  /// Text from _buildSettingsOption.label in driver_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer a Ride'**
  String get offerARide;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver Account Required'**
  String get driverAccountRequired;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You need to register as a driver and add a vehicle to offer rides.'**
  String get youNeedToRegisterAs;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share your journey, earn money'**
  String get shareYourJourneyEarnMoney;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Route'**
  String get yourRoute;

  /// Text from _buildLocationTile.label in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Starting Point'**
  String get startingPoint;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recurring Ride'**
  String get recurringRide;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Offer this ride regularly'**
  String get offerThisRideRegularly;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a vehicle to start offering rides'**
  String get addAVehicleToStart2;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add2;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Seats'**
  String get availableSeats;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max {value} passengers'**
  String maxValuePassengers(Object value);

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Select a vehicle first'**
  String get selectAVehicleFirst;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price per Seat'**
  String get pricePerSeat;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price Negotiable'**
  String get priceNegotiable;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Online Payment'**
  String get acceptOnlinePayment;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Receive payments via Stripe'**
  String get receivePaymentsViaStripe;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Luggage'**
  String get allowLuggage;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Pets'**
  String get allowPets;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Allow Smoking'**
  String get allowSmoking;

  /// Text from _buildPreferenceSwitch.title in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Women Only'**
  String get womenOnly;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max Detour'**
  String get maxDetour;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How far you\'ll go to pick up passengers'**
  String get howFarYouLlGo;

  /// Text from Text in driver_offer_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride created successfully!'**
  String get rideCreatedSuccessfully;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New ride requests will appear here'**
  String get newRideRequestsWillAppear;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Declined Requests'**
  String get noDeclinedRequests;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You haven\'t declined any requests yet'**
  String get youHavenTDeclinedAny;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Request?'**
  String get acceptRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You are about to accept {value1}\'s ride request for {value2} at {value3}.'**
  String youAreAboutToAccept(Object value1, Object value2, Object value3);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request accepted! {value} has been notified.'**
  String requestAcceptedValueHasBeen(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to accept request'**
  String get failedToAcceptRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to decline request'**
  String get failedToDeclineRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Requested {value}'**
  String requestedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value1} seat{value2}'**
  String valueSeatValue2(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} seat{value2} requested'**
  String valueSeatValueRequested(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept Request'**
  String get acceptRequest2;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accepted {value}'**
  String acceptedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1} at {value2}'**
  String valueAtValue(Object value1, Object value2);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Declined {value}'**
  String declinedValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reason: {value}'**
  String reasonValue(Object value);

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline Request'**
  String get declineRequest;

  /// Text from Text in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please let {value} know why you can\'t accept this ride.'**
  String pleaseLetValueKnowWhy(Object value);

  /// Text from InputDecoration.hintText in driver_requests_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please specify...'**
  String get pleaseSpecify;

  /// Text from _buildErrorState in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride not found'**
  String get rideNotFound;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Ride'**
  String get yourRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load ride'**
  String get couldnTLoadRide;

  /// Text from _buildStatItem.label in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats filled'**
  String get seatsFilled;

  /// Text from _buildStatItem.label in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Per seat'**
  String get perSeat;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'~{value}'**
  String value10(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} total seats'**
  String valueTotalSeats(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'New booking requests will appear here'**
  String get newBookingRequestsWillAppear;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers yet'**
  String get noPassengersYet;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Accept booking requests to add passengers'**
  String get acceptBookingRequestsToAdd;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Share Ride'**
  String get shareRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Duplicate Ride'**
  String get duplicateRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Call Passenger'**
  String get callPassenger;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove Passenger'**
  String get removePassenger;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking confirmed for {value}'**
  String bookingConfirmedForValue(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline Booking'**
  String get declineBooking;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Decline booking request from {value}?'**
  String declineBookingRequestFromValue(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove {value} from this ride?'**
  String removeValueFromThisRide(Object value);

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get startRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark this ride as started? Passengers will be notified.'**
  String get markThisRideAsStarted;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Complete Ride'**
  String get completeRide;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Mark this ride as completed? You can then rate your passengers.'**
  String get markThisRideAsCompleted;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? All passengers will be notified and refunded.'**
  String get areYouSureYouWant8;

  /// Text from Text in driver_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Keep Ride'**
  String get keepRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to load ride'**
  String get failedToLoadRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This ride may have been completed or cancelled'**
  String get thisRideMayHaveBeen;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Confirmed'**
  String get rideConfirmed;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Driver on the way'**
  String get driverOnTheWay;

  /// Text from _buildStatusStep in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get rideCompleted;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'• {value} rides'**
  String valueRides2(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Route Details'**
  String get routeDetails;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'per seat'**
  String get perSeat2;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'seats left'**
  String get seatsLeft;

  /// Text from _buildInfoItem in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'departure'**
  String get departure;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Passengers ({value})'**
  String passengersValue(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// Shown when phone dialer is unavailable
  ///
  /// In en, this message translates to:
  /// **'Cannot make phone calls on this device'**
  String get cannotMakePhoneCalls;

  /// Shown when phone dialer launch fails
  ///
  /// In en, this message translates to:
  /// **'Failed to launch phone dialer'**
  String get failedToLaunchDialer;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this ride? Cancellation policies may apply.'**
  String get areYouSureYouWant9;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride cancelled successfully'**
  String get rideCancelledSuccessfully;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel ride: {value}'**
  String failedToCancelRideValue(Object value);

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rate Your Ride'**
  String get rateYourRide;

  /// Text from Text in active_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rating feature coming soon! Thank you for using SportConnect.'**
  String get ratingFeatureComingSoonThank;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Track & manage your rides'**
  String get trackManageYourRides;

  /// Text from _buildTab in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Text from _buildTab in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Active Trips'**
  String get noActiveTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'TRIP IN PROGRESS'**
  String get tripInProgress;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'4.9'**
  String get text49;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Trips'**
  String get noUpcomingTrips;

  /// Text from _buildEmptyState.title in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No Trip History'**
  String get noTripHistory;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Rebook'**
  String get rebook;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find Ride'**
  String get findRide;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Loading your trips...'**
  String get loadingYourTrips;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip?'**
  String get cancelTrip;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel your trip to {value}?'**
  String areYouSureYouWant10(Object value);

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trip cancelled'**
  String get tripCancelled;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Opening chat...'**
  String get openingChat;

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat: {value}'**
  String failedToOpenChatValue(Object value);

  /// Text from Text in rider_my_rides_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Starting call...'**
  String get startingCall;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Find the perfect ride for your journey'**
  String get findThePerfectRideFor;

  /// Text from _buildLocationRow.label in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Where from?'**
  String get whereFrom;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'When?'**
  String get when;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Text from _buildDateChip in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pick Date'**
  String get pickDate;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure time'**
  String get departureTime2;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'How many seats do you need?'**
  String get howManySeatsDoYou;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Available Rides'**
  String get availableRides;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No rides found'**
  String get noRidesFound;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search criteria\nor check back later'**
  String get tryAdjustingYourSearchCriteria;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Finding rides...'**
  String get findingRides;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earliest departure'**
  String get earliestDeparture;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Lowest price'**
  String get lowestPrice;

  /// Text from _buildSortOption in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Highest rated'**
  String get highestRated;

  /// Text from Text in rider_request_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Search failed. Please try again.'**
  String get searchFailedPleaseTryAgain;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Ride Details'**
  String get rideDetails;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} • '**
  String value11(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} left'**
  String valueLeft(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'~{value} min'**
  String valueMin2(Object value);

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} kg CO₂ saved per person'**
  String valueKgCoSavedPer(Object value);

  /// Text from _buildDetailChip in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Negotiable'**
  String get negotiable;

  /// Text from _buildDetailChip in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Online Pay'**
  String get onlinePay;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats:'**
  String get seats3;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Text from _buildSummaryRow in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price per seat'**
  String get pricePerSeat2;

  /// Text from _buildSummaryRow in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Text from InputDecoration.hintText in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Add a note to the driver (optional)'**
  String get addANoteToThe;

  /// Text from Text in rider_view_ride_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking request sent!'**
  String get bookingRequestSent;

  /// Text from _buildInfoChip.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats left'**
  String get seatsLeft2;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get tripDetails;

  /// Text from _buildDetailRow.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departure2;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get amenities;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get pets;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get smoking;

  /// Text from _buildAmenityItem.label in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Luggage'**
  String get luggage;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your Passengers ({value})'**
  String yourPassengersValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value1}/{value2} seats'**
  String valueValueSeats(Object value1, Object value2);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers accepted yet'**
  String get noPassengersAcceptedYet;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'No passengers booked yet'**
  String get noPassengersBookedYet;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} has booked this ride'**
  String valueHasBookedThisRide(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} passengers have booked'**
  String valuePassengersHaveBooked(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pending Requests ({value})'**
  String pendingRequestsValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Request accepted! 🎉'**
  String get requestAccepted;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Seats Booked'**
  String get seatsBooked;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Edit ride feature coming soon!'**
  String get editRideFeatureComingSoon;

  /// Text from _buildPriceRow in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Number of seats'**
  String get numberOfSeats;

  /// Text from _buildPriceRow in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'× {value}'**
  String value12(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Secure payment with Stripe'**
  String get securePaymentWithStripe;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please log in to book a ride'**
  String get pleaseLogInToBook;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment succeeded but booking failed. Please contact support.'**
  String get paymentSucceededButBookingFailed;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {value}'**
  String paymentFailedValue(Object value);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'This driver accepts cash payment only.'**
  String get thisDriverAcceptsCashPayment;

  /// Text from _buildPaymentOption.title in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pay with Cash'**
  String get payWithCash;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to book ride. Please try again.'**
  String get failedToBookRidePlease;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You paid {value1} {value2}'**
  String youPaidValueValue(Object value1, Object value2);

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your ride has been booked.'**
  String get yourRideHasBeenBooked;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'You earned 25 XP!'**
  String get youEarned25Xp;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Back to Search'**
  String get backToSearch;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// Text from Text in ride_detail_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Your ride has been booked. Pay the driver in cash.'**
  String get yourRideHasBeenBooked2;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please enter both locations'**
  String get pleaseEnterBothLocations;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Please select locations from the picker'**
  String get pleaseSelectLocationsFromThe;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Max {value} €'**
  String maxValue(Object value);

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Female only'**
  String get femaleOnly;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Instant book'**
  String get instantBook;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Pet friendly'**
  String get petFriendly;

  /// Text from _buildFilterTag in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}+ rating'**
  String valueRating(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Active Filters'**
  String get activeFilters;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value} rides available'**
  String valueRidesAvailable(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Filters{value}'**
  String filtersValue(Object value);

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'5 €'**
  String get text52;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'100 €'**
  String get text100;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get minimumRating;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'{value}+'**
  String value13(Object value);

  /// Text from _buildToggleChip.label in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Verified driver'**
  String get verifiedDriver2;

  /// Text from _buildToggleChip.label in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Music allowed'**
  String get musicAllowed;

  /// Text from _buildFilterSectionTitle in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// Text from _buildVehicleOption in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Electric'**
  String get electric;

  /// Text from _buildVehicleOption in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Comfort'**
  String get comfort;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Text from Text in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Lowest Price'**
  String get lowestPrice2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Earliest Departure'**
  String get earliestDeparture2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Highest Rated'**
  String get highestRated2;

  /// Text from _buildSortOption.title in ride_search_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Shortest Duration'**
  String get shortestDuration;

  /// User-friendly error message for failed sign-in attempts
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please try again.'**
  String get signInFailedPleaseTry;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Hint text for email input field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Hint text for password input field
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Divider text between social login and email login
  ///
  /// In en, this message translates to:
  /// **'or sign in with email'**
  String get orSignInWithEmail;

  /// Label for Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Label for Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Label for retry button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Stat label for average earnings per ride
  ///
  /// In en, this message translates to:
  /// **'Avg per Ride'**
  String get avgPerRide;

  /// Stat label for total drive time
  ///
  /// In en, this message translates to:
  /// **'Drive Time'**
  String get driveTime;

  /// Greeting used before noon
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Greeting used between noon and evening
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Greeting used in the evening
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Error message when notifications fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// Hint text shown below error message
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get checkYourConnectionAndTry;

  /// Error message when navigating to a chat fails
  ///
  /// In en, this message translates to:
  /// **'Could not open chat'**
  String get couldNotOpenChat;

  /// Hint text for chat search field
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// Tab label for direct/private chats
  ///
  /// In en, this message translates to:
  /// **'Direct'**
  String get direct;

  /// Tab label for group chats
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Tab label for all notifications
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Empty state subtitle for direct chats
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your ride partners'**
  String get startAConversationWith;

  /// Empty state subtitle for group chats
  ///
  /// In en, this message translates to:
  /// **'Join or create a group to start chatting'**
  String get joinOrCreateAGroup;

  /// Empty state subtitle for ride chats
  ///
  /// In en, this message translates to:
  /// **'Join a ride to chat with fellow travelers'**
  String get joinARideToChat;

  /// Quick action button label to create a new ride
  ///
  /// In en, this message translates to:
  /// **'Create Ride'**
  String get driverCreateRide;

  /// Label for weekly earnings metric
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get driverThisWeek;

  /// Label for monthly earnings metric
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get driverThisMonth;

  /// Label for CO2 saved stat card
  ///
  /// In en, this message translates to:
  /// **'CO₂ Saved'**
  String get driverCo2Saved;

  /// Label for hours online stat card
  ///
  /// In en, this message translates to:
  /// **'Hours Online'**
  String get driverHoursOnline;

  /// Title for location permission banner
  ///
  /// In en, this message translates to:
  /// **'Location Required'**
  String get locationRequired;

  /// Subtitle for location permission banner
  ///
  /// In en, this message translates to:
  /// **'Enable location for a better driving experience'**
  String get enableLocationForBetterExperience;

  /// Button text to open app settings for location permission
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Button text to enable location permission
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// Subtitle for empty upcoming rides state
  ///
  /// In en, this message translates to:
  /// **'Create a ride to start earning'**
  String get createARideToStartEarning;

  /// No description provided for @wizardStepWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get wizardStepWelcome;

  /// No description provided for @wizardStepWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s get you started'**
  String get wizardStepWelcomeSubtitle;

  /// No description provided for @wizardStepSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get wizardStepSecurity;

  /// No description provided for @wizardStepSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get wizardStepSecuritySubtitle;

  /// No description provided for @wizardStepRole.
  ///
  /// In en, this message translates to:
  /// **'Your Role'**
  String get wizardStepRole;

  /// No description provided for @wizardStepRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How will you use SportConnect?'**
  String get wizardStepRoleSubtitle;

  /// No description provided for @wizardStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get wizardStepProfile;

  /// No description provided for @wizardStepProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make it personal'**
  String get wizardStepProfileSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFullName;

  /// No description provided for @authFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get authFullNameHint;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get authEmailHint;

  /// No description provided for @authPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get authPhoneOptional;

  /// No description provided for @authPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+216 XX XXX XXX'**
  String get authPhoneHint;

  /// No description provided for @authDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth *'**
  String get authDateOfBirth;

  /// No description provided for @authDobPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to select (must be 18+)'**
  String get authDobPrompt;

  /// No description provided for @authDobMinAge.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to use SportConnect.'**
  String get authDobMinAge;

  /// No description provided for @authDobPicker.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get authDobPicker;

  /// No description provided for @authCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get authCreatePassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Min 8 characters'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get authConfirmPasswordHint;

  /// No description provided for @authAboutYou.
  ///
  /// In en, this message translates to:
  /// **'About You (Optional)'**
  String get authAboutYou;

  /// No description provided for @authAboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit about yourself...'**
  String get authAboutYouHint;

  /// No description provided for @wizardFindRides.
  ///
  /// In en, this message translates to:
  /// **'Find Rides'**
  String get wizardFindRides;

  /// No description provided for @wizardFindRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Search for rides to sporting events, practices, and games'**
  String get wizardFindRidesDesc;

  /// No description provided for @wizardOfferRides.
  ///
  /// In en, this message translates to:
  /// **'Offer Rides'**
  String get wizardOfferRides;

  /// No description provided for @wizardOfferRidesDesc.
  ///
  /// In en, this message translates to:
  /// **'Share your car and earn money while helping others'**
  String get wizardOfferRidesDesc;

  /// No description provided for @wizardContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get wizardContinue;

  /// No description provided for @authAgreeTermsError.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Service'**
  String get authAgreeTermsError;

  /// No description provided for @authDobError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your date of birth.'**
  String get authDobError;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get otpTitle;

  /// No description provided for @otpEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get otpEnterPhone;

  /// No description provided for @otpPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get otpPhoneHint;

  /// No description provided for @otpSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get otpSendCode;

  /// No description provided for @otpVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get otpVerifyTitle;

  /// No description provided for @otpEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get otpEnterCode;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get otpResendCode;

  /// No description provided for @otpInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get otpInvalidCode;

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification code expired. Please request a new one.'**
  String get otpExpired;

  /// No description provided for @otpPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get otpPhoneRequired;

  /// No description provided for @otpInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get otpInvalidPhone;

  /// No description provided for @otpSending.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get otpSending;

  /// No description provided for @otpVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get otpVerifying;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCodeLabel;

  /// No description provided for @otpPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone Verified!'**
  String get otpPhoneVerified;

  /// No description provided for @otpPhoneVerifiedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your phone number has been verified successfully.'**
  String get otpPhoneVerifiedDesc;

  /// No description provided for @otpContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get otpContinue;

  /// No description provided for @otpChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get otpChangePhone;

  /// No description provided for @otpTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get otpTryAgain;

  /// No description provided for @otpBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get otpBackToLogin;

  /// No description provided for @reauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get reauthTitle;

  /// No description provided for @reauthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For your security, please confirm your identity before continuing with this action.'**
  String get reauthSubtitle;

  /// No description provided for @reauthPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get reauthPassword;

  /// No description provided for @reauthPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get reauthPasswordHint;

  /// No description provided for @reauthPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get reauthPasswordRequired;

  /// No description provided for @reauthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get reauthConfirm;

  /// No description provided for @reauthWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Verify with Google'**
  String get reauthWithGoogle;

  /// No description provided for @reauthCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get reauthCancel;

  /// No description provided for @reauthWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get reauthWrongPassword;

  /// No description provided for @reauthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get reauthFailed;

  /// No description provided for @reauthGoogleFailed.
  ///
  /// In en, this message translates to:
  /// **'Google re-authentication failed.'**
  String get reauthGoogleFailed;

  /// No description provided for @emailVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get emailVerifyTitle;

  /// No description provided for @emailVerifyHeading.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get emailVerifyHeading;

  /// No description provided for @emailVerifySentTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to:'**
  String get emailVerifySentTo;

  /// No description provided for @emailVerifyWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification...'**
  String get emailVerifyWaiting;

  /// No description provided for @emailVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get emailVerifyResend;

  /// No description provided for @emailVerifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String emailVerifyResendIn(int seconds);

  /// No description provided for @emailVerifyCheckButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve Verified My Email'**
  String get emailVerifyCheckButton;

  /// No description provided for @emailVerifySent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get emailVerifySent;

  /// No description provided for @emailVerifySendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email. Please try again.'**
  String get emailVerifySendFailed;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email Verified!'**
  String get emailVerified;

  /// No description provided for @emailVerifiedRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Your email has been verified. Redirecting...'**
  String get emailVerifiedRedirecting;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordHeading.
  ///
  /// In en, this message translates to:
  /// **'Update Your Password'**
  String get changePasswordHeading;

  /// No description provided for @changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password with at least 8 characters, including uppercase, lowercase, and numbers.'**
  String get changePasswordDesc;

  /// No description provided for @changePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get changePasswordNew;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get changePasswordUpdate;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password Updated!'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed successfully. Use your new password next time you sign in.'**
  String get changePasswordSuccessDesc;

  /// No description provided for @changePasswordDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get changePasswordDone;

  /// No description provided for @changePasswordWeakError.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Please choose a stronger password.'**
  String get changePasswordWeakError;

  /// No description provided for @changePasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Please try again.'**
  String get changePasswordGenericError;

  /// No description provided for @forgotPasswordCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Check Your Email'**
  String get forgotPasswordCheckEmail;

  /// No description provided for @forgotPasswordResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get forgotPasswordResendEmail;

  /// No description provided for @forgotPasswordResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String forgotPasswordResendIn(int seconds);

  /// No description provided for @forgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// No description provided for @forgotPasswordEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordEmailRequired;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordSendError.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email right now. Please try again.'**
  String get forgotPasswordSendError;

  /// No description provided for @roleSelectionError.
  ///
  /// In en, this message translates to:
  /// **'We could not continue right now. Please try again.'**
  String get roleSelectionError;

  /// No description provided for @accountExistsError.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with a different sign-in method. Try signing in with email/password or the original provider.'**
  String get accountExistsError;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password. Please try again.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Please try again later.'**
  String get loginErrorTooManyRequests;

  /// No description provided for @loginErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get loginErrorNetwork;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @signUpFailedPleaseTry.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed. Please try again.'**
  String get signUpFailedPleaseTry;

  /// No description provided for @periodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodToday;

  /// No description provided for @periodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get periodThisWeek;

  /// No description provided for @periodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get periodThisMonth;

  /// No description provided for @periodAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get periodAllTime;

  /// No description provided for @statRides.
  ///
  /// In en, this message translates to:
  /// **'Rides'**
  String get statRides;

  /// No description provided for @statEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get statEarnings;

  /// No description provided for @statOnlineHours.
  ///
  /// In en, this message translates to:
  /// **'Online Hours'**
  String get statOnlineHours;

  /// No description provided for @statAvgRating.
  ///
  /// In en, this message translates to:
  /// **'Avg Rating'**
  String get statAvgRating;

  /// No description provided for @connectStripeAccount.
  ///
  /// In en, this message translates to:
  /// **'Connect Stripe Account'**
  String get connectStripeAccount;

  /// No description provided for @benefitInstantPayoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get your money in minutes, not days'**
  String get benefitInstantPayoutsDesc;

  /// No description provided for @benefitSecureDesc.
  ///
  /// In en, this message translates to:
  /// **'Bank-level security with Stripe'**
  String get benefitSecureDesc;

  /// No description provided for @benefitTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'See every ride payment in detail'**
  String get benefitTrackingDesc;

  /// No description provided for @benefitLowFeesDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep 85% of every ride payment'**
  String get benefitLowFeesDesc;

  /// No description provided for @pleaseSignInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get pleaseSignInToContinue;

  /// No description provided for @poweredByStripe.
  ///
  /// In en, this message translates to:
  /// **'Powered by Stripe • Secure and encrypted'**
  String get poweredByStripe;

  /// No description provided for @cancelSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Setup?'**
  String get cancelSetupTitle;

  /// No description provided for @cancelSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? You won\'t be able to receive payouts until you complete this setup.'**
  String get cancelSetupMessage;

  /// No description provided for @continueSetup.
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get continueSetup;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get filterRefunded;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get statusRefunded;

  /// No description provided for @statusPartiallyRefunded.
  ///
  /// In en, this message translates to:
  /// **'Partially Refunded'**
  String get statusPartiallyRefunded;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @refundRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Refund request submitted successfully'**
  String get refundRequestSubmitted;

  /// No description provided for @refundRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Refund request failed. Please try again.'**
  String get refundRequestFailed;

  /// No description provided for @payoutDetails.
  ///
  /// In en, this message translates to:
  /// **'Payout Details'**
  String get payoutDetails;

  /// No description provided for @payoutNotFound.
  ///
  /// In en, this message translates to:
  /// **'Payout not found'**
  String get payoutNotFound;

  /// No description provided for @totalPayout.
  ///
  /// In en, this message translates to:
  /// **'Total Payout'**
  String get totalPayout;

  /// No description provided for @breakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get breakdown;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @grossEarnings.
  ///
  /// In en, this message translates to:
  /// **'Gross Earnings'**
  String get grossEarnings;

  /// No description provided for @netPayout.
  ///
  /// In en, this message translates to:
  /// **'Net Payout'**
  String get netPayout;

  /// No description provided for @payoutCreated.
  ///
  /// In en, this message translates to:
  /// **'Payout Created'**
  String get payoutCreated;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @payoutAmount.
  ///
  /// In en, this message translates to:
  /// **'Payout Amount'**
  String get payoutAmount;

  /// No description provided for @instantPayout.
  ///
  /// In en, this message translates to:
  /// **'Instant Payout'**
  String get instantPayout;

  /// No description provided for @payoutDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get payoutDetailsSection;

  /// No description provided for @expectedArrival.
  ///
  /// In en, this message translates to:
  /// **'Expected Arrival'**
  String get expectedArrival;

  /// No description provided for @arrivedAt.
  ///
  /// In en, this message translates to:
  /// **'Arrived At'**
  String get arrivedAt;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @accountEnding.
  ///
  /// In en, this message translates to:
  /// **'Account Ending'**
  String get accountEnding;

  /// No description provided for @failureReason.
  ///
  /// In en, this message translates to:
  /// **'Failure Reason'**
  String get failureReason;

  /// No description provided for @cancelPayout.
  ///
  /// In en, this message translates to:
  /// **'Cancel Payout'**
  String get cancelPayout;

  /// No description provided for @cancelPayoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this payout? This action cannot be undone.'**
  String get cancelPayoutConfirm;

  /// No description provided for @payoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payout cancelled successfully'**
  String get payoutCancelled;

  /// No description provided for @payoutCancelFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel payout. Please try again.'**
  String get payoutCancelFailed;

  /// No description provided for @payoutPendingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout is being processed and will be sent shortly.'**
  String get payoutPendingDesc;

  /// No description provided for @payoutInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get payoutInTransit;

  /// No description provided for @payoutInTransitDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout has been sent and is on its way to your bank.'**
  String get payoutInTransitDesc;

  /// No description provided for @payoutPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get payoutPaid;

  /// No description provided for @payoutPaidDesc.
  ///
  /// In en, this message translates to:
  /// **'Your payout has arrived in your bank account.'**
  String get payoutPaidDesc;

  /// No description provided for @payoutFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'This payout failed. Check the failure reason below.'**
  String get payoutFailedDesc;

  /// No description provided for @payoutCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'This payout was cancelled.'**
  String get payoutCancelledDesc;

  /// No description provided for @stripeVerifyingAccount.
  ///
  /// In en, this message translates to:
  /// **'Verifying your account...'**
  String get stripeVerifyingAccount;

  /// No description provided for @stripeAccountCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create Stripe account. Please try again.'**
  String get stripeAccountCreationFailed;

  /// No description provided for @stripeSetupFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start Stripe setup right now. Please try again.'**
  String get stripeSetupFailed;

  /// No description provided for @stripePageLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load page. Please try again.'**
  String get stripePageLoadFailed;

  /// No description provided for @stripeLoadingConnect.
  ///
  /// In en, this message translates to:
  /// **'Loading Stripe Connect...'**
  String get stripeLoadingConnect;

  /// No description provided for @stripeAdditionalInfoNeeded.
  ///
  /// In en, this message translates to:
  /// **'Additional information needed. Please complete all fields.'**
  String get stripeAdditionalInfoNeeded;

  /// No description provided for @stripeVerifyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify account right now. Please try again.'**
  String get stripeVerifyFailed;

  /// No description provided for @unableToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data. Pull to refresh.'**
  String get unableToLoadData;

  /// No description provided for @exportEarningsReport.
  ///
  /// In en, this message translates to:
  /// **'Earnings Report'**
  String get exportEarningsReport;

  /// No description provided for @exportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated'**
  String get exportGenerated;

  /// No description provided for @exportEarningsSummary.
  ///
  /// In en, this message translates to:
  /// **'EARNINGS SUMMARY'**
  String get exportEarningsSummary;

  /// No description provided for @exportRideStatistics.
  ///
  /// In en, this message translates to:
  /// **'RIDE STATISTICS'**
  String get exportRideStatistics;

  /// No description provided for @exportRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'RECENT TRANSACTIONS'**
  String get exportRecentTransactions;

  /// No description provided for @driverProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get driverProfileTitle;

  /// No description provided for @driverProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself so riders can get to know you.'**
  String get driverProfileSubtitle;

  /// No description provided for @driverCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get driverCityLabel;

  /// No description provided for @driverCityHint.
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get driverCityHint;

  /// No description provided for @driverCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your city'**
  String get driverCityRequired;

  /// No description provided for @driverGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender.'**
  String get driverGenderRequired;

  /// No description provided for @driverInterestsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one interest.'**
  String get driverInterestsRequired;

  /// No description provided for @driverTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get driverTermsLabel;

  /// No description provided for @driverTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept Terms and Privacy to continue.'**
  String get driverTermsRequired;

  /// No description provided for @driverSaveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get driverSaveAndContinue;
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
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
