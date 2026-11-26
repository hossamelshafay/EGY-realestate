import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// The application name displayed in titles and headers.
  ///
  /// In en, this message translates to:
  /// **'EGY Development'**
  String get appName;

  /// Generic loading message.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Label for the retry action button.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Generic error message.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// Empty-state title when a list has no items.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// Empty-state subtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters.'**
  String get noResultsFoundSubtitle;

  /// Semantic label for the back navigation button.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Semantic label for a close / dismiss action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Affirmative action label.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel action label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save action label.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Confirm action label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Delete action label.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Search action label.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Home screen title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Favorites screen title.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Recommendations screen title.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Price Prediction screen title.
  ///
  /// In en, this message translates to:
  /// **'Price Prediction'**
  String get pricePrediction;

  /// AI Chat screen title.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiChat;

  /// Edit Profile screen title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Change Email screen title.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// Change Password screen title.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Real Estate in Egypt'**
  String get welcomeTagline;

  /// No description provided for @featureRecommendations.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendations'**
  String get featureRecommendations;

  /// No description provided for @featurePrice.
  ///
  /// In en, this message translates to:
  /// **'Price Estimation'**
  String get featurePrice;

  /// No description provided for @featureAssistant.
  ///
  /// In en, this message translates to:
  /// **'Property Assistant'**
  String get featureAssistant;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'AR'**
  String get languageArabic;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Set Your Preferences'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Find the Right Property'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Contact the Owner'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **'Choose budget, area, size, and must-have amenities to get better matches.'**
  String get onboardingDescription1;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **'Search, compare, and choose from properties with ease.'**
  String get onboardingDescription2;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **'Explore properties and find a place that feels like home.'**
  String get onboardingDescription3;

  /// No description provided for @swipeUp.
  ///
  /// In en, this message translates to:
  /// **'Swipe Up'**
  String get swipeUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to the EGY Development smart real estate platform'**
  String get authWelcome;

  /// No description provided for @authJoin.
  ///
  /// In en, this message translates to:
  /// **'Join the smart real estate platform in Egypt'**
  String get authJoin;

  /// No description provided for @authResetDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a password reset link.'**
  String get authResetDescription;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @sendReset.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendReset;

  /// No description provided for @resetSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link has been sent.'**
  String get resetSent;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @orContinue.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinue;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @signupStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get signupStepProgress;

  /// No description provided for @chooseAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Avatar'**
  String get chooseAvatarTitle;

  /// No description provided for @chooseAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the look that represents you.'**
  String get chooseAvatarSubtitle;

  /// No description provided for @authProfilePartial.
  ///
  /// In en, this message translates to:
  /// **'Your account was created, but saving your profile failed. Tap Create Account to retry.'**
  String get authProfilePartial;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don?t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @shortPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters.'**
  String get shortPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get invalidCredentials;

  /// No description provided for @emailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get emailInUse;

  /// No description provided for @authNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get authNetwork;

  /// No description provided for @authGeneric.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete this request. Please try again.'**
  String get authGeneric;

  /// No description provided for @authCancelled.
  ///
  /// In en, this message translates to:
  /// **'Sign-in was cancelled.'**
  String get authCancelled;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome home'**
  String get homeWelcome;

  /// No description provided for @homeWelcomeName.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcomeName(String name);

  /// No description provided for @homeMember.
  ///
  /// In en, this message translates to:
  /// **'Your next chapter starts here'**
  String get homeMember;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Area or property type'**
  String get homeSearchHint;

  /// No description provided for @homeSearchSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested properties'**
  String get homeSearchSuggestions;

  /// No description provided for @homeDiscover.
  ///
  /// In en, this message translates to:
  /// **'Find a place to call home'**
  String get homeDiscover;

  /// No description provided for @homeAll.
  ///
  /// In en, this message translates to:
  /// **'All homes'**
  String get homeAll;

  /// No description provided for @homeAllLocations.
  ///
  /// In en, this message translates to:
  /// **'All locations'**
  String get homeAllLocations;

  /// No description provided for @homeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get homeApartment;

  /// No description provided for @homeVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get homeVilla;

  /// No description provided for @homeStudio.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get homeStudio;

  /// No description provided for @homeNewCairo.
  ///
  /// In en, this message translates to:
  /// **'New Cairo'**
  String get homeNewCairo;

  /// No description provided for @homeGiza.
  ///
  /// In en, this message translates to:
  /// **'Giza'**
  String get homeGiza;

  /// No description provided for @homeAlexandria.
  ///
  /// In en, this message translates to:
  /// **'Alexandria'**
  String get homeAlexandria;

  /// No description provided for @homeFeatured.
  ///
  /// In en, this message translates to:
  /// **'Explore Featured Properties'**
  String get homeFeatured;

  /// No description provided for @homePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview homes · not live listings'**
  String get homePreview;

  /// No description provided for @homePreviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Illustrative properties and prices. Favorites are temporary.'**
  String get homePreviewDetails;

  /// No description provided for @homeAiTools.
  ///
  /// In en, this message translates to:
  /// **'AI Tools'**
  String get homeAiTools;

  /// No description provided for @homeHybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid property recommendations'**
  String get homeHybrid;

  /// No description provided for @homeHybridDescription.
  ///
  /// In en, this message translates to:
  /// **'Find a match for your preferences.'**
  String get homeHybridDescription;

  /// No description provided for @homePriceDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore the value of your next home.'**
  String get homePriceDescription;

  /// No description provided for @homeAssistantDescription.
  ///
  /// In en, this message translates to:
  /// **'A little guidance for your property journey.'**
  String get homeAssistantDescription;

  /// No description provided for @homeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get homeComingSoon;

  /// No description provided for @homeFeaturePending.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available in a future update.'**
  String get homeFeaturePending;

  /// No description provided for @homeFilters.
  ///
  /// In en, this message translates to:
  /// **'More filters'**
  String get homeFilters;

  /// No description provided for @homePropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get homePropertyType;

  /// No description provided for @homeLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get homeLocation;

  /// No description provided for @homeSampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample {type}'**
  String homeSampleTitle(String type);

  /// No description provided for @homePrice.
  ///
  /// In en, this message translates to:
  /// **'{price} EGP'**
  String homePrice(String price);

  /// No description provided for @homeBeds.
  ///
  /// In en, this message translates to:
  /// **'{count} beds'**
  String homeBeds(int count);

  /// No description provided for @homeBaths.
  ///
  /// In en, this message translates to:
  /// **'{count} baths'**
  String homeBaths(int count);

  /// No description provided for @homeArea.
  ///
  /// In en, this message translates to:
  /// **'{count} m²'**
  String homeArea(int count);

  /// No description provided for @homeSave.
  ///
  /// In en, this message translates to:
  /// **'Save property'**
  String get homeSave;

  /// No description provided for @homeUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get homeUnsave;

  /// No description provided for @homeMenu.
  ///
  /// In en, this message translates to:
  /// **'Open navigation menu'**
  String get homeMenu;

  /// No description provided for @homeLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get homeLogout;

  /// No description provided for @homeLogoutError.
  ///
  /// In en, this message translates to:
  /// **'Could not log out. Please try again.'**
  String get homeLogoutError;

  /// No description provided for @homeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeLanguage;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get homeAssistantTitle;

  /// No description provided for @homeAssistantBannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Personalized guidance to find a place that feels like home.'**
  String get homeAssistantBannerDescription;

  /// No description provided for @homeAssistantCta.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get homeAssistantCta;

  /// No description provided for @homeResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get homeResidential;

  /// No description provided for @homeCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get homeCommercial;

  /// No description provided for @homeForSale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get homeForSale;

  /// No description provided for @homeForRent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get homeForRent;

  /// No description provided for @homeResidentialSale.
  ///
  /// In en, this message translates to:
  /// **'Residential for Sale'**
  String get homeResidentialSale;

  /// No description provided for @homeResidentialRent.
  ///
  /// In en, this message translates to:
  /// **'Residential for Rent'**
  String get homeResidentialRent;

  /// No description provided for @homeCommercialSale.
  ///
  /// In en, this message translates to:
  /// **'Commercial for Sale'**
  String get homeCommercialSale;

  /// No description provided for @homeCommercialRent.
  ///
  /// In en, this message translates to:
  /// **'Commercial for Rent'**
  String get homeCommercialRent;

  /// No description provided for @homePredictorTitle.
  ///
  /// In en, this message translates to:
  /// **'Price Predictor'**
  String get homePredictorTitle;

  /// No description provided for @homePreviewPage.
  ///
  /// In en, this message translates to:
  /// **'Preview property {page} of {total}'**
  String homePreviewPage(int page, int total);

  /// No description provided for @aiSignIn.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get aiSignIn;

  /// No description provided for @aiInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Check the entered values and try again.'**
  String get aiInvalidInput;

  /// No description provided for @aiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This service is currently unavailable. Please try again later.'**
  String get aiUnavailable;

  /// No description provided for @aiRateLimit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later.'**
  String get aiRateLimit;

  /// No description provided for @aiAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get aiAll;

  /// No description provided for @aiSpecifications.
  ///
  /// In en, this message translates to:
  /// **'Property specifications'**
  String get aiSpecifications;

  /// No description provided for @aiPredictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Estimate property value in the Egyptian market'**
  String get aiPredictSubtitle;

  /// No description provided for @aiSize.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get aiSize;

  /// No description provided for @aiBedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get aiBedrooms;

  /// No description provided for @aiBathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get aiBathrooms;

  /// No description provided for @aiLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude (22–32)'**
  String get aiLatitude;

  /// No description provided for @aiLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude (24–38)'**
  String get aiLongitude;

  /// No description provided for @aiCoordinatesHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter the property\'s exact coordinates. Estimates depend on the location you provide.'**
  String get aiCoordinatesHelp;

  /// No description provided for @aiCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate estimated price'**
  String get aiCalculate;

  /// No description provided for @aiReset.
  ///
  /// In en, this message translates to:
  /// **'Value another property'**
  String get aiReset;

  /// No description provided for @aiEstimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated price'**
  String get aiEstimatedPrice;

  /// No description provided for @aiHeuristicRange.
  ///
  /// In en, this message translates to:
  /// **'Indicative range, not a confidence interval'**
  String get aiHeuristicRange;

  /// No description provided for @aiMonthly.
  ///
  /// In en, this message translates to:
  /// **'EGP / month'**
  String get aiMonthly;

  /// No description provided for @aiCurrency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get aiCurrency;

  /// No description provided for @aiMinimumPrice.
  ///
  /// In en, this message translates to:
  /// **'Minimum price (EGP)'**
  String get aiMinimumPrice;

  /// No description provided for @aiMaximumPrice.
  ///
  /// In en, this message translates to:
  /// **'Maximum price (EGP)'**
  String get aiMaximumPrice;

  /// No description provided for @aiCity.
  ///
  /// In en, this message translates to:
  /// **'City name (optional)'**
  String get aiCity;

  /// No description provided for @aiTypeOptional.
  ///
  /// In en, this message translates to:
  /// **'Property type (optional)'**
  String get aiTypeOptional;

  /// No description provided for @aiRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore properties matching your preferences'**
  String get aiRecommendationsSubtitle;

  /// No description provided for @aiLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get aiLoadMore;

  /// No description provided for @aiSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar properties'**
  String get aiSimilar;

  /// No description provided for @aiFound.
  ///
  /// In en, this message translates to:
  /// **'Matching properties'**
  String get aiFound;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your smart property assistant'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Tell me what kind of property you are looking for.'**
  String get aiChatWelcome;

  /// No description provided for @aiMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about properties…'**
  String get aiMessageHint;

  /// No description provided for @aiSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get aiSend;

  /// No description provided for @aiNewChat.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get aiNewChat;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'Preparing your response…'**
  String get aiThinking;

  /// No description provided for @aiMissingPrice.
  ///
  /// In en, this message translates to:
  /// **'Price not listed'**
  String get aiMissingPrice;

  /// No description provided for @aiRangeValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a number in the allowed range.'**
  String get aiRangeValidation;

  /// No description provided for @aiPropertyType.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get aiPropertyType;

  /// No description provided for @aiCategory.
  ///
  /// In en, this message translates to:
  /// **'Property category'**
  String get aiCategory;

  /// No description provided for @propertyTypeApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get propertyTypeApartment;

  /// No description provided for @propertyTypeBulkRentUnit.
  ///
  /// In en, this message translates to:
  /// **'Bulk Rent Unit'**
  String get propertyTypeBulkRentUnit;

  /// No description provided for @propertyTypeBulkSaleUnit.
  ///
  /// In en, this message translates to:
  /// **'Bulk Sale Unit'**
  String get propertyTypeBulkSaleUnit;

  /// No description provided for @propertyTypeBungalow.
  ///
  /// In en, this message translates to:
  /// **'Bungalow'**
  String get propertyTypeBungalow;

  /// No description provided for @propertyTypeCabin.
  ///
  /// In en, this message translates to:
  /// **'Cabin'**
  String get propertyTypeCabin;

  /// No description provided for @propertyTypeCafeteria.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get propertyTypeCafeteria;

  /// No description provided for @propertyTypeChalet.
  ///
  /// In en, this message translates to:
  /// **'Chalet'**
  String get propertyTypeChalet;

  /// No description provided for @propertyTypeClinic.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get propertyTypeClinic;

  /// No description provided for @propertyTypeCoWorkingSpace.
  ///
  /// In en, this message translates to:
  /// **'Co-Working Space'**
  String get propertyTypeCoWorkingSpace;

  /// No description provided for @propertyTypeDuplex.
  ///
  /// In en, this message translates to:
  /// **'Duplex'**
  String get propertyTypeDuplex;

  /// No description provided for @propertyTypeFactory.
  ///
  /// In en, this message translates to:
  /// **'Factory'**
  String get propertyTypeFactory;

  /// No description provided for @propertyTypeFarm.
  ///
  /// In en, this message translates to:
  /// **'Farm'**
  String get propertyTypeFarm;

  /// No description provided for @propertyTypeFullFloor.
  ///
  /// In en, this message translates to:
  /// **'Full Floor'**
  String get propertyTypeFullFloor;

  /// No description provided for @propertyTypeHalfFloor.
  ///
  /// In en, this message translates to:
  /// **'Half Floor'**
  String get propertyTypeHalfFloor;

  /// No description provided for @propertyTypeHotelApartment.
  ///
  /// In en, this message translates to:
  /// **'Hotel Apartment'**
  String get propertyTypeHotelApartment;

  /// No description provided for @propertyTypeLand.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get propertyTypeLand;

  /// No description provided for @propertyTypeMedicalFacility.
  ///
  /// In en, this message translates to:
  /// **'Medical Facility'**
  String get propertyTypeMedicalFacility;

  /// No description provided for @propertyTypeOfficeSpace.
  ///
  /// In en, this message translates to:
  /// **'Office Space'**
  String get propertyTypeOfficeSpace;

  /// No description provided for @propertyTypePalace.
  ///
  /// In en, this message translates to:
  /// **'Palace'**
  String get propertyTypePalace;

  /// No description provided for @propertyTypePenthouse.
  ///
  /// In en, this message translates to:
  /// **'Penthouse'**
  String get propertyTypePenthouse;

  /// No description provided for @propertyTypeRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get propertyTypeRestaurant;

  /// No description provided for @propertyTypeRetail.
  ///
  /// In en, this message translates to:
  /// **'Retail'**
  String get propertyTypeRetail;

  /// No description provided for @propertyTypeRoof.
  ///
  /// In en, this message translates to:
  /// **'Roof'**
  String get propertyTypeRoof;

  /// No description provided for @propertyTypeShop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get propertyTypeShop;

  /// No description provided for @propertyTypeShowRoom.
  ///
  /// In en, this message translates to:
  /// **'Show Room'**
  String get propertyTypeShowRoom;

  /// No description provided for @propertyTypeStaffAccommodation.
  ///
  /// In en, this message translates to:
  /// **'Staff Accommodation'**
  String get propertyTypeStaffAccommodation;

  /// No description provided for @propertyTypeTownhouse.
  ///
  /// In en, this message translates to:
  /// **'Townhouse'**
  String get propertyTypeTownhouse;

  /// No description provided for @propertyTypeTwinHouse.
  ///
  /// In en, this message translates to:
  /// **'Twin House'**
  String get propertyTypeTwinHouse;

  /// No description provided for @propertyTypeVilla.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get propertyTypeVilla;

  /// No description provided for @propertyTypeWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get propertyTypeWarehouse;

  /// No description provided for @propertyTypeWholeBuilding.
  ///
  /// In en, this message translates to:
  /// **'Whole Building'**
  String get propertyTypeWholeBuilding;

  /// No description provided for @propertyTypeIVilla.
  ///
  /// In en, this message translates to:
  /// **'iVilla'**
  String get propertyTypeIVilla;

  /// No description provided for @propertyTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other property type'**
  String get propertyTypeOther;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get themeDark;

  /// No description provided for @propertyDetails.
  ///
  /// In en, this message translates to:
  /// **'Property details'**
  String get propertyDetails;

  /// No description provided for @propertyDescription.
  ///
  /// In en, this message translates to:
  /// **'About this property'**
  String get propertyDescription;

  /// No description provided for @propertyAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get propertyAmenities;

  /// No description provided for @propertyPhotos.
  ///
  /// In en, this message translates to:
  /// **'More photos'**
  String get propertyPhotos;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved properties yet.'**
  String get favoritesEmpty;

  /// No description provided for @favoritesUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Saved properties are unavailable. Please try again.'**
  String get favoritesUnavailable;

  /// No description provided for @featuredPage.
  ///
  /// In en, this message translates to:
  /// **'Property {page} of {count}'**
  String featuredPage(int page, int count);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatar;

  /// No description provided for @avatarRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an avatar before continuing.'**
  String get avatarRequired;

  /// No description provided for @avatarMasculine.
  ///
  /// In en, this message translates to:
  /// **'Masculine avatar {number}'**
  String avatarMasculine(int number);

  /// No description provided for @avatarFeminine.
  ///
  /// In en, this message translates to:
  /// **'Feminine avatar {number}'**
  String avatarFeminine(int number);

  /// No description provided for @accountDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get accountDisplayName;

  /// No description provided for @accountNameRules.
  ///
  /// In en, this message translates to:
  /// **'Use a name between 2 and 60 characters.'**
  String get accountNameRules;

  /// No description provided for @accountSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get accountSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get profileSaved;

  /// No description provided for @profileSyncPending.
  ///
  /// In en, this message translates to:
  /// **'Cloud profile sync failed. Retry Save to sync your changes.'**
  String get profileSyncPending;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @emailUnverified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get emailUnverified;

  /// No description provided for @sendVerification.
  ///
  /// In en, this message translates to:
  /// **'Send verification email'**
  String get sendVerification;

  /// No description provided for @verificationSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox, then refresh.'**
  String get verificationSent;

  /// No description provided for @refreshAccount.
  ///
  /// In en, this message translates to:
  /// **'Refresh account'**
  String get refreshAccount;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get newEmail;

  /// No description provided for @emailChangeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Verify the new email using the link sent by Firebase; your current email stays active until then.'**
  String get emailChangeSent;

  /// No description provided for @emailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Email updated successfully.'**
  String get emailUpdated;

  /// No description provided for @emailLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'The verification link has expired or is invalid. Request a new email change.'**
  String get emailLinkExpired;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get passwordChanged;

  /// No description provided for @accountPasswordRules.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters for the new password.'**
  String get accountPasswordRules;

  /// No description provided for @accountReauthError.
  ///
  /// In en, this message translates to:
  /// **'Identity verification failed. Check your credentials and try again.'**
  String get accountReauthError;

  /// No description provided for @accountPermission.
  ///
  /// In en, this message translates to:
  /// **'Cloud access is denied. Check permissions or retry after access is restored.'**
  String get accountPermission;

  /// No description provided for @accountCleanupIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Deletion did not finish. Some account data may already be removed. Retry cleanup before deleting the account.'**
  String get accountCleanupIncomplete;

  /// No description provided for @accountTryLater.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a while and try again.'**
  String get accountTryLater;

  /// No description provided for @accountProviderManaged.
  ///
  /// In en, this message translates to:
  /// **'This account uses its sign-in provider for authentication.'**
  String get accountProviderManaged;

  /// No description provided for @accountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The account service is unavailable. Check your connection and retry.'**
  String get accountUnavailable;

  /// No description provided for @googleReauth.
  ///
  /// In en, this message translates to:
  /// **'Google will ask you to confirm this same account before continuing.'**
  String get googleReauth;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this account and its app-managed profile, Favorites, and local chat history? This cannot be undone. Deletion stops if cloud cleanup cannot be verified.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'I understand. Delete my account'**
  String get deleteAccountConfirm;

  /// No description provided for @changeEmailInfo.
  ///
  /// In en, this message translates to:
  /// **'Reauthenticate, then verify the new mailbox. The account UID and saved data remain the same.'**
  String get changeEmailInfo;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get accountSecurity;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileAppearance;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
