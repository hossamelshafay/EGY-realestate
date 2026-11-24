# EGY DEVELOPMENT — Design System

> **Version:** 1.0  
> **Last Updated:** 2026-11-17  
> **Mode:** Light Mode (Dark Mode architecturally supported, deferred)

---

## 1. Color Tokens

### Primary Palette

| Token | Hex | Usage |
|---|---|---|
| `primaryNavy` | `#031A2D` | Headers, drawer background, primary text, dark surfaces |
| `secondaryNavy` | `#06233E` | Drawer gradient end, secondary dark surfaces |
| `primaryGold` | `#E5A11A` | Primary buttons, active chips, accent icons, logo |
| `secondaryGold` | `#D4941A` | Gold gradient end, hover/pressed state |
| `white` | `#FFFFFF` | Card backgrounds, text on dark surfaces |
| `offWhite` | `#F7F8FA` | Screen backgrounds, light surfaces |

### Supporting Colors

| Token | Hex | Usage |
|---|---|---|
| `textPrimary` | `#031A2D` | Headings, important labels (same as primaryNavy) |
| `textSecondary` | `#6B7280` | Body text, descriptions, hints |
| `textTertiary` | `#9CA3AF` | Placeholder text, disabled labels |
| `textOnDark` | `#FFFFFF` | Text on navy/dark backgrounds |
| `textOnGold` | `#FFFFFF` | Text on gold buttons |
| `destructiveRed` | `#DC2626` | Delete account, error messages, validation errors |
| `successGreen` | `#16A34A` | Success messages, confirmation states |
| `infoBlue` | `#2563EB` | Links, info actions |
| `borderLight` | `#E5E7EB` | Card borders, dividers |
| `inputFill` | `#F3F4F6` | Text field background fill |
| `chipInactive` | `#E5E7EB` | Inactive category/filter chips |
| `chipActiveText` | `#FFFFFF` | Text on active (gold) chips |
| `shimmerBase` | `#E5E7EB` | Shimmer loading base color |
| `shimmerHighlight` | `#F3F4F6` | Shimmer loading highlight color |

### Gradients

| Name | Colors | Usage |
|---|---|---|
| `goldGradient` | `#E5A11A` → `#D4941A` | Primary buttons (Login, Register, Search, Predict) |
| `navyGradient` | `#031A2D` → `#06233E` | Header backgrounds, drawer background |

### Flutter Implementation

```dart
// app/theme/app_colors.dart

import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const Color primaryNavy = Color(0xFF031A2D);
  static const Color secondaryNavy = Color(0xFF06233E);
  static const Color primaryGold = Color(0xFFE5A11A);
  static const Color secondaryGold = Color(0xFFD4941A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F8FA);

  // Text
  static const Color textPrimary = Color(0xFF031A2D);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Semantic
  static const Color destructiveRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);
  static const Color infoBlue = Color(0xFF2563EB);

  // Surface
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color inputFill = Color(0xFFF3F4F6);
  static const Color chipInactive = Color(0xFFE5E7EB);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryGold, secondaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [primaryNavy, secondaryNavy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
```

---

## 2. Typography

### Font Family: Cairo

**Cairo** is recommended as the primary font family. It provides excellent Arabic and Latin character support, is available via `google_fonts`, and has the right weights for our design.

### Type Scale

| Style Name | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 32 | Bold (700) | 1.2 | Hero prices, splash logo text |
| `headlineLarge` | 24 | Bold (700) | 1.3 | Screen titles |
| `headlineMedium` | 20 | SemiBold (600) | 1.3 | Section headings |
| `titleLarge` | 18 | SemiBold (600) | 1.4 | Card titles, dialog titles |
| `titleMedium` | 16 | Medium (500) | 1.4 | Subtitles, drawer items |
| `bodyLarge` | 16 | Regular (400) | 1.5 | Body text, descriptions |
| `bodyMedium` | 14 | Regular (400) | 1.5 | Secondary body text |
| `bodySmall` | 12 | Regular (400) | 1.4 | Captions, metadata |
| `labelLarge` | 16 | SemiBold (600) | 1.0 | Button text |
| `labelMedium` | 14 | Medium (500) | 1.0 | Chip text, tab labels |
| `labelSmall` | 12 | Medium (500) | 1.0 | Badges, tiny labels |

### Flutter Implementation

```dart
// app/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.cairo(
      fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    ),
    headlineLarge: GoogleFonts.cairo(
      fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.cairo(
      fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.cairo(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.cairo(
      fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
    ),
    bodyLarge: GoogleFonts.cairo(
      fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    ),
    bodyMedium: GoogleFonts.cairo(
      fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.cairo(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textTertiary,
    ),
    labelLarge: GoogleFonts.cairo(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white,
    ),
    labelMedium: GoogleFonts.cairo(
      fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
    ),
    labelSmall: GoogleFonts.cairo(
      fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textTertiary,
    ),
  );
}
```

---

## 3. Spacing System

Based on a **4px grid** for consistent spacing across the app.

| Token | Value | Usage |
|---|---|---|
| `xs` | 4px | Tight inner padding, icon gaps |
| `sm` | 8px | Between related elements, chip padding |
| `md` | 12px | Card inner padding, list item spacing |
| `base` | 16px | Standard padding, section spacing |
| `lg` | 20px | Between sections |
| `xl` | 24px | Screen horizontal padding, header padding |
| `xxl` | 32px | Major section separation |
| `xxxl` | 48px | Top padding below headers |

### Border Radius

| Token | Value | Usage |
|---|---|---|
| `radiusSm` | 8px | Chips, small buttons |
| `radiusMd` | 12px | Text fields, small cards |
| `radiusLg` | 16px | Cards, dialogs |
| `radiusXl` | 24px | White content panels (top corners only) |
| `radiusFull` | 999px | Circular buttons, avatars |

### Flutter Implementation

```dart
// app/theme/app_dimensions.dart

abstract class AppDimensions {
  // Spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Border Radius
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Specific
  static const double headerHeight = 200;
  static const double drawerWidth = 280;
  static const double buttonHeight = 52;
  static const double textFieldHeight = 52;
  static const double cardElevation = 2;
  static const double propertyCardImageHeight = 180;
  static const double iconSizeSm = 20;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
}
```

---

## 4. Layout Architecture

### Screen Layout Pattern: Navy Header + White Panel

Most screens follow this two-part layout:

```
┌─────────────────────────────────────┐
│          NAVY HEADER                │
│    (gradient background)            │
│    Back Button    Title    Action   │
│                                     │
├────────────────────────────────────┐│
│  ╭─────────────────────────────╮  ││
│  │      WHITE CONTENT PANEL     │  ││
│  │   (rounded top corners 24)   │  ││
│  │                              │  ││
│  │   Scrollable content area    │  ││
│  │                              │  ││
│  │                              │  ││
│  └──────────────────────────────┘  ││
└─────────────────────────────────────┘
```

### Implementation Strategy

```dart
class ScreenLayout extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Widget? action;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navy Header
          AppHeader(
            title: title,
            onBack: onBack,
            action: action,
          ),
          // White Content Panel
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXl),
                  topRight: Radius.circular(AppDimensions.radiusXl),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Home Screen Layout (Special Case)

The Home screen uses a taller header with the user greeting, search bar, and category chips integrated into the header area, before transitioning to the white content panel.

---

## 5. Component Specifications

### 5.1 AppHeader

Reusable navy gradient header used across most screens.

| Property | Type | Description |
|---|---|---|
| `title` | `String` | Header title text (white, headlineLarge) |
| `onBack` | `VoidCallback?` | If provided, shows a back arrow button |
| `action` | `Widget?` | Optional trailing action (icon button) |
| `showDrawerToggle` | `bool` | Show hamburger menu icon (Home screen) |

**Visual:**
- Background: `navyGradient` (top to bottom)
- Height: ~200px (varies by content)
- Safe area respected (status bar)
- Title: white, centered or left-aligned
- Back button: white arrow icon, left side

---

### 5.2 PrimaryButton (Gold Gradient)

The main call-to-action button used for Login, Register, Search, Predict, etc.

| Property | Type | Description |
|---|---|---|
| `text` | `String` | Button label |
| `onPressed` | `VoidCallback?` | Tap handler (null = disabled) |
| `isLoading` | `bool` | Shows circular progress indicator |
| `isFullWidth` | `bool` | Expands to fill width (default: true) |

**Visual:**
- Background: `goldGradient`
- Height: 52px
- Border radius: 12px
- Text: white, labelLarge (16px, SemiBold)
- Disabled: 50% opacity
- Loading: white CircularProgressIndicator, text hidden

```dart
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: AppDimensions.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed != null ? AppColors.goldGradient : null,
          color: onPressed == null ? AppColors.chipInactive : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2,
                  ),
                )
              : Text(text, style: Theme.of(context).textTheme.labelLarge),
        ),
      ),
    );
  }
}
```

---

### 5.3 SecondaryButton (Outlined Navy)

Used for secondary actions (Reset, Cancel, Predict Another).

**Visual:**
- Background: transparent
- Border: 1.5px navy outline
- Height: 52px
- Border radius: 12px
- Text: navy, labelLarge

---

### 5.4 AppTextField

Standard text input field used across auth and form screens.

| Property | Type | Description |
|---|---|---|
| `label` | `String` | Field label (above) |
| `hint` | `String` | Placeholder text |
| `controller` | `TextEditingController` | Input controller |
| `prefixIcon` | `IconData?` | Leading icon |
| `suffixIcon` | `Widget?` | Trailing widget (visibility toggle, etc.) |
| `obscureText` | `bool` | Password masking |
| `validator` | `FormFieldValidator?` | Validation function |
| `keyboardType` | `TextInputType` | Keyboard type |

**Visual:**
- Fill color: `inputFill` (#F3F4F6)
- Border radius: 12px
- Height: 52px
- Border: none by default; `destructiveRed` on error
- Prefix icon: `textTertiary` color
- Text: `textPrimary`
- Hint: `textTertiary`
- Error text: `destructiveRed`, bodySmall

---

### 5.5 PropertyCard

Reusable property listing card used in Home, Recommendations, and Favorites.

| Property | Type | Description |
|---|---|---|
| `property` | `PropertyEntity` | Property data object |
| `onTap` | `VoidCallback` | Card tap handler |
| `onFavoriteToggle` | `VoidCallback` | Heart button handler |
| `isFavorited` | `bool` | Filled vs outlined heart |
| `matchScore` | `double?` | AI match percentage (Recommendations only) |

**Visual:**
- White background, rounded corners (16px)
- Subtle shadow (elevation 2)
- **Image area:** Top portion, 180px height, rounded top corners, `CachedNetworkImage`
- **Favorite button:** Heart icon, top-right of image, in a small circular white container
- **Info area:** Below image, padding 12px
  - Title: titleLarge, navy
  - Price: headlineMedium, gold, formatted (e.g., "1,500,000 EGP")
  - Location: bodyMedium, secondary text, with location pin icon
  - **Specs row:** Icons + text for bedrooms, bathrooms, area (m²)
  - **Match score** (if present): Small gold badge "92% Match"

---

### 5.6 CategoryChip

Horizontal scrollable chips for filtering (Home, Recommendations).

**Visual:**
- **Active:** Gold background (#E5A11A), white text
- **Inactive:** Light gray background (#E5E7EB), navy text
- Border radius: 8px
- Padding: 8px horizontal, 4px vertical
- Text: labelMedium

---

### 5.7 SettingsTile

Settings list item used in the Settings screen.

**Visual:**
- White background card, rounded corners (16px)
- Padding: 16px
- **Left:** Colored icon in a subtle circle background
- **Center:** Title text (titleMedium)
- **Right:** Chevron icon (gray)
- **Delete Account variant:** Icon and text in `destructiveRed`

---

### 5.8 ChatBubble

Message bubble for the AI Chat screen.

**User Bubble:**
- Aligned right
- Background: `primaryNavy`
- Text: white
- Border radius: 16px (bottom-right: 4px)

**AI Bubble:**
- Aligned left
- Background: `offWhite`
- Text: `textPrimary`
- Border radius: 16px (bottom-left: 4px)

---

## 6. State Widgets

### LoadingView

Shimmer-based loading placeholder. Uses the shimmer package with `shimmerBase` and `shimmerHighlight` colors.

- **List loading:** 3–4 card-sized shimmer rectangles
- **Detail loading:** Header shimmer + content blocks
- **Inline loading:** Small circular progress indicator (gold)

### ErrorView

Centered error state with icon, message, and retry button.

- **Icon:** Warning icon in `destructiveRed`
- **Message:** bodyLarge, `textSecondary`
- **Retry button:** SecondaryButton ("Try Again")

### EmptyView

Centered empty state with illustration, title, and optional CTA.

- **Illustration:** SVG/Lottie placeholder illustration
- **Title:** headlineMedium, navy
- **Subtitle:** bodyLarge, `textSecondary`
- **CTA:** PrimaryButton (optional, e.g., "Browse Properties")

---

## 7. Responsive Breakpoints

| Breakpoint | Width | Behavior |
|---|---|---|
| **Mobile** | < 600px | Single column, full-width cards |
| **Tablet** | 600–900px | 2-column grid for property cards |
| **Large Tablet** | > 900px | 3-column grid, persistent drawer |

> [!NOTE]
> Phase 1 focuses on mobile. Tablet layouts are architecturally supported via `LayoutBuilder` or `MediaQuery` but not polished until Phase 2.

---

## 8. Design Reference Image Map

| # | File | Screen | Key Observations |
|---|---|---|---|
| 01 | `01_splash.png` | Splash | Gold "EGY" logo + "DEVELOPMENT" on deep navy background. Centered. Minimal. |
| 02a | `02_onboardingone.png` | Onboarding Page 1 | Illustration + title + description. Page dots at bottom. Skip button top-right. |
| 02b | `02_onboardingtwo.png` | Onboarding Page 2 | Same layout as 02a with different illustration and text. |
| 02c | `02_onboardingthree.png` | Onboarding Page 3 | Same layout. "Get Started" button replaces next arrow. |
| 03 | `03_login.jpg` | Login | Navy header area with logo. White panel with email, password fields. Gold "Login" button. Links to Register and Forgot Password. Soft skyline background. |
| 04 | `04_register.jpg` | Register | Similar to login layout. Additional fields (name, confirm password). Gold "Register" button. |
| 05 | `05_home.jpg` | Home | Navy header with greeting + search bar. Category chips below. Property card grid/list. White background panel. |
| 06 | `06_navigation_drawer.jpg` | Drawer | Navy gradient background. Profile photo + name + email at top. Menu items with gold icons. Active item highlighted. |
| 07 | `07_recommendation_filters.jpg` | Recommendation Filters | Navy header "Find Properties". White panel with filter fields (type, location, price, rooms, area). Gold "Search" button at bottom. |
| 08 | `08_recommendation_results.jpg` | Recommendation Results | Navy header "Results". Property cards with AI match score badges. Scrollable list. |
| 09 | `09_price_prediction.jpg` | Price Prediction Input | Navy header "Price Prediction". Form fields for property attributes. Gold "Predict" button. |
| 10 | `10_price_prediction_results.jpg` | Price Prediction Results | Large predicted price in gold. Property summary below. Navy header. |
| 11 | `11_ai_chat.png` | AI Chat | Navy header "AI Assistant". Chat bubbles (user right, AI left). Input bar at bottom with send button. |
| 12 | `12_favorites.png` | Favorites | Navy header "Favorites". Property cards list. Heart icons filled. Empty state if none. |
| 13 | `13_settings.png` | Settings | Navy header "Settings". White rounded cards for each option. Chevrons. Red "Delete Account" at bottom. |
| 14 | `14_change_email.png` | Change Email | Navy header. Current email (read-only). New email field. Password for confirmation. |
| 15 | `15_change_password.png` | Change Password | Navy header. Current password, new password, confirm password fields. |
| 16 | `16_edit_profile.png` | Edit Profile | Navy header. Profile photo (editable). Name field. Gold "Save" button. |
| 17 | `17_forgetpass.jpg` | Forgot Password | Navy header. Email field. "Send Reset Link" button. Back to login link. |

---

## 9. Icon System

Use **Material Icons** as the primary icon set (bundled with Flutter). Supplement with `flutter_svg` for custom brand assets (logo).

### Common Icons

| Context | Icon | Color |
|---|---|---|
| Back navigation | `Icons.arrow_back_ios_new` | White (on navy header) |
| Drawer toggle | `Icons.menu` | White |
| Search | `Icons.search` | `textTertiary` (in fields), White (on header) |
| Favorite (empty) | `Icons.favorite_border` | `textTertiary` |
| Favorite (filled) | `Icons.favorite` | `destructiveRed` |
| Email | `Icons.email_outlined` | `textTertiary` |
| Password | `Icons.lock_outline` | `textTertiary` |
| Visibility on | `Icons.visibility` | `textTertiary` |
| Visibility off | `Icons.visibility_off` | `textTertiary` |
| Person | `Icons.person_outline` | `textTertiary` |
| Settings | `Icons.settings_outlined` | `textSecondary` |
| Logout | `Icons.logout` | `destructiveRed` |
| Delete | `Icons.delete_outline` | `destructiveRed` |
| Bedrooms | `Icons.bed_outlined` | `textSecondary` |
| Bathrooms | `Icons.bathtub_outlined` | `textSecondary` |
| Area | `Icons.square_foot` | `textSecondary` |
| Location | `Icons.location_on_outlined` | `textSecondary` |
| Home | `Icons.home_outlined` | Gold (drawer) |
| AI Chat | `Icons.chat_bubble_outline` | Gold (drawer) |
| Predict | `Icons.trending_up` | Gold (drawer) |
| Recommend | `Icons.recommend` | Gold (drawer) |
| Send message | `Icons.send` | `primaryGold` |
| Chevron | `Icons.chevron_right` | `textTertiary` |

---

## 10. Animation Guidelines

| Animation | Duration | Curve | Context |
|---|---|---|---|
| Splash fade-in | 800ms | `Curves.easeIn` | Logo appearance |
| Page transitions | 300ms | `Curves.easeInOut` | go_router transitions |
| Onboarding swipe | 400ms | `Curves.easeInOut` | PageView page change |
| Button press | 100ms | `Curves.easeIn` | Scale down to 0.95 |
| Favorite toggle | 200ms | `Curves.bounceOut` | Heart icon scale pop |
| Shimmer | 1500ms | Linear | Loading shimmer cycle |
| Chat bubble appear | 300ms | `Curves.easeOut` | Slide up + fade in |
| Drawer open/close | 300ms | `Curves.easeInOut` | Standard Flutter drawer |

---

## 11. Dark Mode (Deferred — Architecture Only)

Dark Mode is **not implemented in Phase 1** but the architecture supports it via `ThemeData`:

```dart
// app/theme/app_theme.dart

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGold,
      secondary: AppColors.primaryNavy,
      surface: AppColors.white,
      error: AppColors.destructiveRed,
    ),
    scaffoldBackgroundColor: AppColors.offWhite,
    textTheme: AppTextStyles.textTheme,
    // ... component themes
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    // TODO: Define dark mode colors
    // Swap navy backgrounds for darker shade
    // Keep gold accents
    // White text on dark surfaces
  );
}
```

> [!IMPORTANT]
> Always use `Theme.of(context)` to reference colors and text styles in widgets — never hardcode `AppColors` directly in widget trees. This ensures Dark Mode works when implemented.
