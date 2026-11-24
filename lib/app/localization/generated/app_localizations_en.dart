// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'EGY Development';

  @override
  String get loading => 'Loading…';

  @override
  String get retryButton => 'Retry';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get noResultsFoundSubtitle => 'Try adjusting your search or filters.';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get favorites => 'Favorites';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get pricePrediction => 'Price Prediction';

  @override
  String get aiChat => 'AI Assistant';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get welcomeTagline => 'Smart Real Estate in Egypt';

  @override
  String get featureRecommendations => 'AI Recommendations';

  @override
  String get featurePrice => 'Price Estimation';

  @override
  String get featureAssistant => 'Property Assistant';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageArabic => 'AR';

  @override
  String get skip => 'Skip';

  @override
  String get onboardingTitle1 => 'Set Your Preferences';

  @override
  String get onboardingTitle2 => 'Find the Right Property';

  @override
  String get onboardingTitle3 => 'Contact the Owner';

  @override
  String get onboardingDescription1 =>
      'Choose budget, area, size, and must-have amenities to get better matches.';

  @override
  String get onboardingDescription2 =>
      'Search, compare, and choose from properties with ease.';

  @override
  String get onboardingDescription3 =>
      'Explore properties and find a place that feels like home.';

  @override
  String get swipeUp => 'Swipe Up';

  @override
  String get createAccount => 'Create Account';

  @override
  String get logIn => 'Log In';

  @override
  String get authWelcome =>
      'Welcome back to the EGY Development smart real estate platform';

  @override
  String get authJoin => 'Join the smart real estate platform in Egypt';

  @override
  String get authResetDescription =>
      'Enter your email to receive a password reset link.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get sendReset => 'Send reset link';

  @override
  String get resetSent =>
      'If an account exists for this email, a reset link has been sent.';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get orContinue => 'Or continue with';

  @override
  String get noAccount => 'Don?t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get shortPassword => 'Use at least 8 characters.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get invalidCredentials => 'Email or password is incorrect.';

  @override
  String get emailInUse => 'This email is already in use.';

  @override
  String get authNetwork => 'Check your internet connection and try again.';

  @override
  String get authGeneric =>
      'Unable to complete this request. Please try again.';

  @override
  String get authCancelled => 'Sign-in was cancelled.';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get homeWelcome => 'Welcome home';

  @override
  String homeWelcomeName(String name) {
    return 'Welcome, $name';
  }

  @override
  String get homeMember => 'Your next chapter starts here';

  @override
  String get homeSearchHint => 'Search for property, area, or developer...';

  @override
  String get homeDiscover => 'Find a place to call home';

  @override
  String get homeAll => 'All homes';

  @override
  String get homeAllLocations => 'All locations';

  @override
  String get homeApartment => 'Apartment';

  @override
  String get homeVilla => 'Villa';

  @override
  String get homeStudio => 'Studio';

  @override
  String get homeNewCairo => 'New Cairo';

  @override
  String get homeGiza => 'Giza';

  @override
  String get homeAlexandria => 'Alexandria';

  @override
  String get homeFeatured => 'Explore Featured Properties';

  @override
  String get homePreview => 'Preview homes · not live listings';

  @override
  String get homePreviewDetails =>
      'Illustrative properties and prices. Favorites are temporary.';

  @override
  String get homeAiTools => 'AI Tools';

  @override
  String get homeHybrid => 'Hybrid property recommendations';

  @override
  String get homeHybridDescription => 'Find a match for your preferences.';

  @override
  String get homePriceDescription => 'Explore the value of your next home.';

  @override
  String get homeAssistantDescription =>
      'A little guidance for your property journey.';

  @override
  String get homeComingSoon => 'Coming soon';

  @override
  String get homeFeaturePending =>
      'This feature will be available in a future update.';

  @override
  String get homeFilters => 'More filters';

  @override
  String get homePropertyType => 'Property type';

  @override
  String get homeLocation => 'Location';

  @override
  String homeSampleTitle(String type) {
    return 'Sample $type';
  }

  @override
  String homePrice(String price) {
    return '$price EGP';
  }

  @override
  String homeBeds(int count) {
    return '$count beds';
  }

  @override
  String homeBaths(int count) {
    return '$count baths';
  }

  @override
  String homeArea(int count) {
    return '$count m²';
  }

  @override
  String get homeSave => 'Save property';

  @override
  String get homeUnsave => 'Remove from Favorites';

  @override
  String get homeMenu => 'Open navigation menu';

  @override
  String get homeLogout => 'Log out';

  @override
  String get homeLogoutError => 'Could not log out. Please try again.';

  @override
  String get homeLanguage => 'Language';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeAssistantTitle => 'AI Assistant';

  @override
  String get homeAssistantBannerDescription =>
      'Personalized guidance to find a place that feels like home.';

  @override
  String get homeResidential => 'Residential';

  @override
  String get homeCommercial => 'Commercial';

  @override
  String get homeForSale => 'For Sale';

  @override
  String get homeForRent => 'For Rent';

  @override
  String get homeResidentialSale => 'Residential for Sale';

  @override
  String get homeResidentialRent => 'Residential for Rent';

  @override
  String get homeCommercialSale => 'Commercial for Sale';

  @override
  String get homeCommercialRent => 'Commercial for Rent';

  @override
  String get homePredictorTitle => 'Price Predictor';

  @override
  String homePreviewPage(int page, int total) {
    return 'Preview property $page of $total';
  }

  @override
  String get aiSignIn => 'Please sign in again to continue.';

  @override
  String get aiInvalidInput => 'Check the entered values and try again.';

  @override
  String get aiUnavailable =>
      'This service is currently unavailable. Please try again later.';

  @override
  String get aiRateLimit => 'Too many requests. Please try again later.';

  @override
  String get aiAll => 'All';

  @override
  String get aiSpecifications => 'Property specifications';

  @override
  String get aiPredictSubtitle =>
      'Estimate property value in the Egyptian market';

  @override
  String get aiSize => 'Area (m²)';

  @override
  String get aiBedrooms => 'Bedrooms';

  @override
  String get aiBathrooms => 'Bathrooms';

  @override
  String get aiLatitude => 'Latitude (22–32)';

  @override
  String get aiLongitude => 'Longitude (24–38)';

  @override
  String get aiCoordinatesHelp =>
      'Enter the property\'s exact coordinates. Estimates depend on the location you provide.';

  @override
  String get aiCalculate => 'Calculate estimated price';

  @override
  String get aiReset => 'Value another property';

  @override
  String get aiEstimatedPrice => 'Estimated price';

  @override
  String get aiHeuristicRange => 'Indicative range, not a confidence interval';

  @override
  String get aiMonthly => 'EGP / month';

  @override
  String get aiCurrency => 'EGP';

  @override
  String get aiMinimumPrice => 'Minimum price (EGP)';

  @override
  String get aiMaximumPrice => 'Maximum price (EGP)';

  @override
  String get aiCity => 'City name (optional)';

  @override
  String get aiTypeOptional => 'Property type (optional)';

  @override
  String get aiRecommendationsSubtitle =>
      'Explore properties matching your preferences';

  @override
  String get aiLoadMore => 'Load more';

  @override
  String get aiSimilar => 'Similar properties';

  @override
  String get aiFound => 'Matching properties';

  @override
  String get aiChatSubtitle => 'Your smart property assistant';

  @override
  String get aiChatWelcome =>
      'Welcome! Tell me what kind of property you are looking for.';

  @override
  String get aiMessageHint => 'Ask about properties…';

  @override
  String get aiSend => 'Send';

  @override
  String get aiNewChat => 'New conversation';

  @override
  String get aiThinking => 'Preparing your response…';

  @override
  String get aiMissingPrice => 'Price not listed';

  @override
  String get aiRangeValidation => 'Enter a number in the allowed range.';

  @override
  String get aiPropertyType => 'Property type';

  @override
  String get aiCategory => 'Property category';

  @override
  String get propertyTypeApartment => 'Apartment';

  @override
  String get propertyTypeBulkRentUnit => 'Bulk Rent Unit';

  @override
  String get propertyTypeBulkSaleUnit => 'Bulk Sale Unit';

  @override
  String get propertyTypeBungalow => 'Bungalow';

  @override
  String get propertyTypeCabin => 'Cabin';

  @override
  String get propertyTypeCafeteria => 'Cafeteria';

  @override
  String get propertyTypeChalet => 'Chalet';

  @override
  String get propertyTypeClinic => 'Clinic';

  @override
  String get propertyTypeCoWorkingSpace => 'Co-Working Space';

  @override
  String get propertyTypeDuplex => 'Duplex';

  @override
  String get propertyTypeFactory => 'Factory';

  @override
  String get propertyTypeFarm => 'Farm';

  @override
  String get propertyTypeFullFloor => 'Full Floor';

  @override
  String get propertyTypeHalfFloor => 'Half Floor';

  @override
  String get propertyTypeHotelApartment => 'Hotel Apartment';

  @override
  String get propertyTypeLand => 'Land';

  @override
  String get propertyTypeMedicalFacility => 'Medical Facility';

  @override
  String get propertyTypeOfficeSpace => 'Office Space';

  @override
  String get propertyTypePalace => 'Palace';

  @override
  String get propertyTypePenthouse => 'Penthouse';

  @override
  String get propertyTypeRestaurant => 'Restaurant';

  @override
  String get propertyTypeRetail => 'Retail';

  @override
  String get propertyTypeRoof => 'Roof';

  @override
  String get propertyTypeShop => 'Shop';

  @override
  String get propertyTypeShowRoom => 'Show Room';

  @override
  String get propertyTypeStaffAccommodation => 'Staff Accommodation';

  @override
  String get propertyTypeTownhouse => 'Townhouse';

  @override
  String get propertyTypeTwinHouse => 'Twin House';

  @override
  String get propertyTypeVilla => 'Villa';

  @override
  String get propertyTypeWarehouse => 'Warehouse';

  @override
  String get propertyTypeWholeBuilding => 'Whole Building';

  @override
  String get propertyTypeIVilla => 'iVilla';

  @override
  String get propertyTypeOther => 'Other property type';

  @override
  String get propertyDetails => 'Property details';

  @override
  String get favoritesEmpty => 'No saved properties yet.';

  @override
  String get favoritesUnavailable =>
      'Saved properties are unavailable. Please try again.';

  @override
  String featuredPage(int page, int count) {
    return 'Property $page of $count';
  }
}
