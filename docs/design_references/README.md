# EGY DEVELOPMENT — Design References Index

All 19 UI reference images are located in this directory.
Images represent the **approved visual direction** for the EGY DEVELOPMENT application.

> [!IMPORTANT]
> These are design references only. Do not modify, rename, or delete these files.
> All Flutter implementations must match these designs faithfully.
> See [DESIGN_SYSTEM.md](../DESIGN_SYSTEM.md) for extracted design tokens.

---

## Image Index

### Authentication & Onboarding

| File | Screen | Key Visual Elements |
|---|---|---|
| `01_splash.png` | **Splash Screen** | Navy gradient full-screen, centered EGY gold serif logo with swoosh underline, "DEVELOPMENT" small text below |
| `02_onboardingone.png` | **Onboarding Slide 1** | Off-white/peach background (`#FDF5E9`), 3D house illustration, headline text, page dots at bottom, "Swipe Up" with chevron arrows |
| `02_onboardingtwo.png` | **Onboarding Slide 2** | Same layout as slide 1, different 3D illustration and copy |
| `02_onboardingthree.png` | **Onboarding Slide 3** | Same layout, final slide with CTA "Get Started" button |
| `03_login.jpg` | **Login Screen** | Navy header panel (app bar area), white rounded card panel, email/password fields, gold gradient "Log In" button with arrow icon, Google + Apple social buttons, "Don't have an account? Register" link |
| `04_register.jpg` | **Register Screen** | Same layout as login, additional Name field, "Already have an account? Log In" link |
| `17_forgetpass.jpg` | **Forgot Password** | Email field only, gold "Send Reset Email" button |

### Core Navigation

| File | Screen | Key Visual Elements |
|---|---|---|
| `05_home.jpg` | **Home Screen** | Navy gradient header with search bar + EGY logo, white panel below, 5 category chips (All / Residential Sale / Residential Rent / Commercial Sale / Commercial Rent), featured property cards with image + price + specs |
| `06_navigation_drawer.jpg` | **Navigation Drawer** | Full navy gradient background, circular profile photo, user name + "عضو في EGY Development" subtitle, gold-accented items for Recommendations & Price Prediction, regular items for AI Chat / Favorites / Settings / Language |

### AI Features

| File | Screen | Key Visual Elements |
|---|---|---|
| `07_recommendation_filters.jpg` | **Recommendation Filters** | Navy header, white panel, category chips (same 5 as home), dropdowns for property type / area / bedrooms / bathrooms / price range |
| `08_recommendation_results.jpg` | **Recommendation Results** | List of property cards matching filters, each with image, price, location, specs badges |
| `09_price_prediction.jpg` | **Price Prediction Form** | Navy header, white panel, category chips, dropdowns for property type / location (city) / area (m²) / bathrooms / bedrooms, gold "Predict Price" button |
| `10_price_prediction_results.jpg` | **Price Prediction Results** | Predicted price prominently displayed, price range (low/high), market stats, SHAP feature breakdown bars, similar properties section |
| `11_ai_chat.png` | **AI Chatbot** | Chat interface, bot greeting message, structured choice buttons (not free text first), message bubbles, input bar at bottom |

### Property & Favorites

| File | Screen | Key Visual Elements |
|---|---|---|
| `12_favorites.png` | **Favorites** | List of saved property cards, heart icon (filled/active), swipe-to-remove or delete button |

### Settings

| File | Screen | Key Visual Elements |
|---|---|---|
| `13_settings.png` | **Settings** | 4 cards only: Edit Profile / Change Email / Change Password / Delete Account (red destructive) |
| `14_change_email.png` | **Change Email** | Current email (read-only), new email field, confirm button |
| `15_change_password.png` | **Change Password** | Current password, new password, confirm password fields |
| `16_edit_profile.png` | **Edit Profile** | Avatar circle with camera icon, name field, phone number field, save button |

---

## Visual Language Summary

### Color Palette (extracted from images)

| Token | Hex | Usage |
|---|---|---|
| `navy` | `#031A2D` | Headers, drawer background, app bar |
| `navyLight` | `#0A2540` | Gradient end, card overlays |
| `gold` | `#E5A11A` | Logo, active chips, primary buttons, gold icons |
| `goldDark` | `#D4941A` | Button gradient end, pressed states |
| `white` | `#FFFFFF` | Content panels, card backgrounds |
| `offWhite` | `#F7F8FA` | Input field backgrounds, page background |
| `peach` | `#FDF5E9` | Onboarding background tint |
| `destructiveRed` | `#E53935` | Delete Account button |
| `textPrimary` | `#1A1A2E` | Main body text |
| `textSecondary` | `#6B7280` | Subtitles, hints |

### Layout Pattern

```
┌─────────────────────────────────┐
│  Navy Gradient Header           │  ← NavBar + screen title
│  (with rounded bottom corners)  │
├─────────────────────────────────┤
│                                 │
│  White Rounded Panel            │  ← Content area
│  (top corners: 24px radius)     │    Scrollable
│                                 │
└─────────────────────────────────┘
```

### Typography

- **Logo:** Custom serif font (EGY gold logo — must use SVG/PNG asset, NOT a text widget)
- **Headings:** Bold, navy or white depending on background
- **Body:** Regular weight, `#1A1A2E`
- **Arabic:** Cairo font family for Arabic locale
- **English:** Default system sans-serif (Inter or Roboto acceptable)

### Key UI Components (from images)

| Component | Description |
|---|---|
| **Category Chips** | Horizontal scrollable row; active = gold background + white text; inactive = light gray |
| **Property Card** | Image top + price badge + title + location + specs row (beds/baths/area icons) |
| **Drawer Items** | Gold icon + label for AI features; standard icon for others; dividers between groups |
| **Form Fields** | Rounded rectangle, off-white background, subtle border, label above |
| **Primary Button** | Gold gradient, full width, rounded corners, white bold text, optional trailing icon |
| **Social Buttons** | Outlined, full width, provider logo + text |
| **Settings Cards** | White card with icon, title, chevron; Delete Account in red |

---

## Missing Assets (Action Required)

> [!CAUTION]
> The following assets are visible in design references but **NOT found** in the Flutter project `lib/assets/` directory.
> The project owner must supply these before Phase 2 (Splash & Onboarding) can be implemented.

| Asset | Required For | Description |
|---|---|---|
| `egy_logo.svg` or `egy_logo.png` | Splash, Drawer, App Bar | EGY gold serif logo with swoosh underline |
| Onboarding illustration 1 | Onboarding Slide 1 | 3D house/building illustration |
| Onboarding illustration 2 | Onboarding Slide 2 | 3D illustration |
| Onboarding illustration 3 | Onboarding Slide 3 | 3D illustration |

---

*Last updated: 2026-11-17 — Initial design references index*
