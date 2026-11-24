// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'EGY للتطوير';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retryButton => 'إعادة المحاولة';

  @override
  String get somethingWentWrong => 'حدث خطأ ما.';

  @override
  String get noResultsFound => 'لا توجد نتائج.';

  @override
  String get noResultsFoundSubtitle => 'حاول تعديل بحثك أو المرشحات.';

  @override
  String get back => 'رجوع';

  @override
  String get close => 'إغلاق';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get search => 'بحث';

  @override
  String get settings => 'الإعدادات';

  @override
  String get home => 'الرئيسية';

  @override
  String get favorites => 'المفضلة';

  @override
  String get recommendations => 'التوصيات';

  @override
  String get pricePrediction => 'توقع السعر';

  @override
  String get aiChat => 'المساعد الذكي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get welcomeTagline => 'عقارات ذكية في مصر';

  @override
  String get featureRecommendations => 'توصيات ذكية';

  @override
  String get featurePrice => 'تقدير الأسعار';

  @override
  String get featureAssistant => 'المساعد العقاري';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get languageEnglish => 'EN';

  @override
  String get languageArabic => 'AR';

  @override
  String get skip => 'تخطي';

  @override
  String get onboardingTitle1 => 'حدد تفضيلاتك';

  @override
  String get onboardingTitle2 => 'اعثر على العقار المناسب';

  @override
  String get onboardingTitle3 => 'تواصل مع المالك';

  @override
  String get onboardingDescription1 =>
      'اختر الميزانية والمنطقة والمساحة والمرافق لتحصل على نتائج أفضل.';

  @override
  String get onboardingDescription2 =>
      'ابحث عن العقارات وقارن بينها واختر ما يناسبك.';

  @override
  String get onboardingDescription3 =>
      'استكشف العقارات واعثر على المكان المناسب لك.';

  @override
  String get swipeUp => 'اسحب للأعلى';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get authWelcome => 'مرحباً بعودتك إلى منصة EGY العقارية';

  @override
  String get authJoin => 'انضم إلى المنصة العقارية الذكية في مصر';

  @override
  String get authResetDescription =>
      'أدخل بريدك الإلكتروني لاستلام رابط إعادة تعيين كلمة المرور.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get resetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get sendReset => 'إرسال رابط إعادة التعيين';

  @override
  String get resetSent =>
      'إذا كان البريد مرتبطاً بحساب، فقد أُرسل رابط إعادة التعيين.';

  @override
  String get continueGoogle => 'المتابعة باستخدام Google';

  @override
  String get orContinue => 'أو تابع باستخدام';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get haveAccount => 'لديك حساب بالفعل؟';

  @override
  String get requiredField => 'هذا الحقل مطلوب.';

  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صحيحاً.';

  @override
  String get shortPassword => 'استخدم ٨ أحرف على الأقل.';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get invalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get emailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get authNetwork => 'تحقق من اتصال الإنترنت وحاول مجدداً.';

  @override
  String get authGeneric => 'تعذر إكمال الطلب. حاول مرة أخرى.';

  @override
  String get authCancelled => 'تم إلغاء تسجيل الدخول.';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get homeWelcome => 'أهلاً بك';

  @override
  String homeWelcomeName(String name) {
    return 'أهلاً، $name';
  }

  @override
  String get homeMember => 'خطوتك القادمة تبدأ هنا';

  @override
  String get homeSearchHint => 'ابحث عن عقار أو منطقة أو مطوّر...';

  @override
  String get homeDiscover => 'اكتشف منزلك القادم';

  @override
  String get homeAll => 'كل العقارات';

  @override
  String get homeAllLocations => 'كل المناطق';

  @override
  String get homeApartment => 'شقة';

  @override
  String get homeVilla => 'فيلا';

  @override
  String get homeStudio => 'استوديو';

  @override
  String get homeNewCairo => 'القاهرة الجديدة';

  @override
  String get homeGiza => 'الجيزة';

  @override
  String get homeAlexandria => 'الإسكندرية';

  @override
  String get homeFeatured => 'استكشف العقارات المميزة';

  @override
  String get homePreview => 'عقارات تجريبية · ليست عروضاً حقيقية';

  @override
  String get homePreviewDetails => 'عقارات وأسعار توضيحية. المفضلة مؤقتة.';

  @override
  String get homeAiTools => 'أدوات الذكاء الاصطناعي';

  @override
  String get homeHybrid => 'توصيات عقارية هجينة';

  @override
  String get homeHybridDescription => 'اكتشف ما يناسب تفضيلاتك.';

  @override
  String get homePriceDescription => 'اكتشف القيمة التقديرية لمنزلك القادم.';

  @override
  String get homeAssistantDescription => 'إرشادات تساعدك في رحلتك العقارية.';

  @override
  String get homeComingSoon => 'قريباً';

  @override
  String get homeFeaturePending => 'ستتوفر هذه الميزة في تحديث قادم.';

  @override
  String get homeFilters => 'المزيد من الفلاتر';

  @override
  String get homePropertyType => 'نوع العقار';

  @override
  String get homeLocation => 'المنطقة';

  @override
  String homeSampleTitle(String type) {
    return '$type تجريبية';
  }

  @override
  String homePrice(String price) {
    return '$price ج.م';
  }

  @override
  String homeBeds(int count) {
    return '$count غرف';
  }

  @override
  String homeBaths(int count) {
    return '$count حمام';
  }

  @override
  String homeArea(int count) {
    return '$count م²';
  }

  @override
  String get homeSave => 'حفظ العقار';

  @override
  String get homeUnsave => 'إزالة من المفضلة';

  @override
  String get homeMenu => 'فتح قائمة التنقل';

  @override
  String get homeLogout => 'تسجيل الخروج';

  @override
  String get homeLogoutError => 'تعذر تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get homeLanguage => 'اللغة';

  @override
  String get homeViewAll => 'عرض الكل';

  @override
  String get homeAssistantTitle => 'المساعد الذكي';

  @override
  String get homeAssistantBannerDescription =>
      'مساعدة تناسب تفضيلاتك لاكتشاف منزلك القادم.';

  @override
  String get homeResidential => 'سكني';

  @override
  String get homeCommercial => 'تجاري';

  @override
  String get homeForSale => 'للبيع';

  @override
  String get homeForRent => 'للإيجار';

  @override
  String get homeResidentialSale => 'عقارات سكنية للبيع';

  @override
  String get homeResidentialRent => 'عقارات سكنية للإيجار';

  @override
  String get homeCommercialSale => 'عقارات تجارية للبيع';

  @override
  String get homeCommercialRent => 'عقارات تجارية للإيجار';

  @override
  String get homePredictorTitle => 'توقع السعر';

  @override
  String homePreviewPage(int page, int total) {
    return 'العقار التجريبي $page من $total';
  }

  @override
  String get aiSignIn => 'يرجى تسجيل الدخول مرة أخرى للمتابعة.';

  @override
  String get aiInvalidInput => 'راجع القيم المدخلة وحاول مرة أخرى.';

  @override
  String get aiUnavailable =>
      'هذه الخدمة غير متاحة حاليًا. يرجى المحاولة لاحقًا.';

  @override
  String get aiRateLimit => 'طلبات كثيرة. يرجى المحاولة لاحقًا.';

  @override
  String get aiAll => 'الكل';

  @override
  String get aiSpecifications => 'مواصفات العقار';

  @override
  String get aiPredictSubtitle => 'تقدير قيمة العقار في السوق المصري';

  @override
  String get aiSize => 'المساحة (م²)';

  @override
  String get aiBedrooms => 'غرف النوم';

  @override
  String get aiBathrooms => 'الحمامات';

  @override
  String get aiLatitude => 'خط العرض (٢٢–٣٢)';

  @override
  String get aiLongitude => 'خط الطول (٢٤–٣٨)';

  @override
  String get aiCoordinatesHelp =>
      'أدخل إحداثيات العقار بدقة. يعتمد التقدير على الموقع الذي تحدده.';

  @override
  String get aiCalculate => 'احسب السعر التقديري';

  @override
  String get aiReset => 'تقييم عقار آخر';

  @override
  String get aiEstimatedPrice => 'السعر التقديري';

  @override
  String get aiHeuristicRange => 'نطاق تقريبي وليس فاصل ثقة';

  @override
  String get aiMonthly => 'جنيه / شهر';

  @override
  String get aiCurrency => 'جنيه';

  @override
  String get aiMinimumPrice => 'الحد الأدنى للسعر (جنيه)';

  @override
  String get aiMaximumPrice => 'الحد الأقصى للسعر (جنيه)';

  @override
  String get aiCity => 'اسم المدينة (اختياري)';

  @override
  String get aiTypeOptional => 'نوع العقار (اختياري)';

  @override
  String get aiRecommendationsSubtitle => 'استكشف عقارات تناسب تفضيلاتك';

  @override
  String get aiLoadMore => 'عرض المزيد';

  @override
  String get aiSimilar => 'عقارات مشابهة';

  @override
  String get aiFound => 'العقارات المطابقة';

  @override
  String get aiChatSubtitle => 'مساعدك العقاري الذكي';

  @override
  String get aiChatWelcome => 'مرحبًا! أخبرني عن العقار الذي تبحث عنه.';

  @override
  String get aiMessageHint => 'اسأل عن العقارات…';

  @override
  String get aiSend => 'إرسال';

  @override
  String get aiNewChat => 'محادثة جديدة';

  @override
  String get aiThinking => 'جارٍ تحضير الرد…';

  @override
  String get aiMissingPrice => 'السعر غير متاح';

  @override
  String get aiRangeValidation => 'أدخل رقمًا ضمن النطاق المسموح.';

  @override
  String get aiPropertyType => 'نوع العقار';

  @override
  String get aiCategory => 'فئة العقار';

  @override
  String get propertyTypeApartment => 'شقة';

  @override
  String get propertyTypeBulkRentUnit => 'وحدات للإيجار بالجملة';

  @override
  String get propertyTypeBulkSaleUnit => 'وحدات للبيع بالجملة';

  @override
  String get propertyTypeBungalow => 'منزل من طابق واحد';

  @override
  String get propertyTypeCabin => 'كوخ';

  @override
  String get propertyTypeCafeteria => 'كافيتريا';

  @override
  String get propertyTypeChalet => 'شاليه';

  @override
  String get propertyTypeClinic => 'عيادة';

  @override
  String get propertyTypeCoWorkingSpace => 'مساحة عمل مشتركة';

  @override
  String get propertyTypeDuplex => 'دوبلكس';

  @override
  String get propertyTypeFactory => 'مصنع';

  @override
  String get propertyTypeFarm => 'مزرعة';

  @override
  String get propertyTypeFullFloor => 'طابق كامل';

  @override
  String get propertyTypeHalfFloor => 'نصف طابق';

  @override
  String get propertyTypeHotelApartment => 'شقة فندقية';

  @override
  String get propertyTypeLand => 'أرض';

  @override
  String get propertyTypeMedicalFacility => 'منشأة طبية';

  @override
  String get propertyTypeOfficeSpace => 'مكتب';

  @override
  String get propertyTypePalace => 'قصر';

  @override
  String get propertyTypePenthouse => 'بنتهاوس';

  @override
  String get propertyTypeRestaurant => 'مطعم';

  @override
  String get propertyTypeRetail => 'مساحة للبيع بالتجزئة';

  @override
  String get propertyTypeRoof => 'روف';

  @override
  String get propertyTypeShop => 'محل';

  @override
  String get propertyTypeShowRoom => 'صالة عرض';

  @override
  String get propertyTypeStaffAccommodation => 'سكن العاملين';

  @override
  String get propertyTypeTownhouse => 'تاون هاوس';

  @override
  String get propertyTypeTwinHouse => 'توين هاوس';

  @override
  String get propertyTypeVilla => 'فيلا';

  @override
  String get propertyTypeWarehouse => 'مستودع';

  @override
  String get propertyTypeWholeBuilding => 'مبنى كامل';

  @override
  String get propertyTypeIVilla => 'آي فيلا';

  @override
  String get propertyTypeOther => 'نوع عقار آخر';

  @override
  String get propertyDetails => 'تفاصيل العقار';

  @override
  String get favoritesEmpty => 'لا توجد عقارات محفوظة بعد.';

  @override
  String get favoritesUnavailable =>
      'العقارات المحفوظة غير متاحة. يرجى المحاولة مرة أخرى.';

  @override
  String featuredPage(int page, int count) {
    return 'العقار $page من $count';
  }
}
