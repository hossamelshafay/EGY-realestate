# EGY DEVELOPMENT — Feature Specifications

> **Version:** 1.0  
> **Last Updated:** 2026-11-17  
> **Total Screens:** 17 (across 11 feature modules)

---

## 1. User Journey Overview

```
App Launch
    │
    ▼
┌─────────┐    First Launch    ┌──────────────┐
│  Splash  │ ───────────────► │  Onboarding   │
│          │                   │  (3 pages)    │
└─────────┘                   └──────────────┘
    │                                │
    │ Returning User                 │ Get Started
    │ (authenticated)                ▼
    │                         ┌──────────────┐
    │                         │    Login      │◄──── Forgot Password
    │                         │              │
    │                         │  Register ───┘
    │                         └──────────────┘
    │                                │
    │                                │ Success
    ▼                                ▼
┌──────────────────────────────────────────┐
│                 HOME                      │
│          (Navigation Drawer)              │
├──────────┬──────────┬──────────┬─────────┤
│ Recommend│  Price   │ AI Chat  │Favorites│
│ ations   │Prediction│          │         │
├──────────┴──────────┴──────────┴─────────┤
│              Settings                     │
│   Edit Profile │ Change Email │ Password  │
└──────────────────────────────────────────┘
```

---

## 2. Feature Specifications

---

### 2.1 Splash Screen

**Design Reference:** `01_splash.png`

**Description:** Brand introduction screen shown on app launch. Displays the gold "EGY DEVELOPMENT" logo centered on a deep navy background.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Show logo with fade-in animation |
| Checking | Determine auth status + onboarding completion |
| Navigate | Route to Onboarding (first launch), Login (unauthenticated), or Home (authenticated) |

**Business Requirements:**
- Display for minimum 2 seconds (brand exposure)
- Check `SharedPreferences` for onboarding completion flag
- Check `FirebaseAuth.currentUser` for authentication status

**Dependencies:**
- `SharedPreferences` (onboarding flag)
- `FirebaseAuth` (auth check)

**Acceptance Criteria:**
- [ ] Logo displays centered with fade-in animation
- [ ] Routes to Onboarding on first launch
- [ ] Routes to Login if not authenticated
- [ ] Routes to Home if authenticated
- [ ] No user interaction required (auto-navigate)

---

### 2.2 Onboarding

**Design References:** `02_onboardingone.png`, `02_onboardingtwo.png`, `02_onboardingthree.png`

**Description:** Three-page introduction showcasing the app's key features. Swipeable pages with a page indicator and "Get Started" button on the final page.

**UI States:**

| State | Behavior |
|---|---|
| Page 1 | First onboarding illustration + text |
| Page 2 | Second onboarding illustration + text |
| Page 3 | Third onboarding illustration + text + "Get Started" button |

**Business Requirements:**
- Three swipeable pages with illustrations and descriptive text
- Page indicator (dots) showing current position
- "Skip" option available on pages 1 and 2
- "Get Started" button on page 3 navigates to Login
- Mark onboarding as completed in `SharedPreferences`
- Never show onboarding again after completion

**Dependencies:**
- `SharedPreferences` (persist completion flag)

**Acceptance Criteria:**
- [ ] Three pages swipeable horizontally
- [ ] Page indicator updates on swipe
- [ ] "Skip" navigates directly to Login
- [ ] "Get Started" on page 3 navigates to Login
- [ ] Onboarding flag persisted — not shown on subsequent launches

---

### 2.3 Authentication — Login

**Design Reference:** `03_login.jpg`

**Description:** Email and password login screen with the EGY DEVELOPMENT branding. Features a gold gradient login button, links to Register and Forgot Password.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Empty form with email and password fields |
| Validating | Client-side validation feedback |
| Loading | Button shows spinner, fields disabled |
| Success | Navigate to Home |
| Error | Show error message (snackbar or inline) |

**Business Requirements:**
- Email field with email validation
- Password field with visibility toggle
- "Remember Me" checkbox (optional, store in SharedPreferences)
- "Login" button — **verify button color against `03_login.jpg` before coding; do not default to gold — the design reference may show a blue primary button on this screen**
- "Forgot Password?" link → Forgot Password screen
- "Don't have an account? Register" link → Register screen
- Firebase Auth `signInWithEmailAndPassword`

**Dependencies:**
- `firebase_auth` (Firebase Authentication)
- `SharedPreferences` (remember me)

**Acceptance Criteria:**
- [ ] Email validates format before submission
- [ ] Password field has visibility toggle
- [ ] Loading state disables form and shows spinner
- [ ] Successful login navigates to Home
- [ ] Invalid credentials show localized error message
- [ ] Network errors handled gracefully
- [ ] Links to Register and Forgot Password work

---

### 2.4 Authentication — Register

**Design Reference:** `04_register.jpg`

**Description:** Account creation screen with name, email, password, and confirm password fields.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Empty form |
| Validating | Real-time field validation |
| Loading | Spinner, fields disabled |
| Success | Navigate to Home (auto-login after registration) |
| Error | Show specific error (email already in use, weak password, etc.) |

**Business Requirements:**
- Full name field
- Email field with validation
- Password field with strength requirements (min 8 chars)
- Confirm password field with match validation
- "Register" button — gold gradient
- "Already have an account? Login" link → Login screen
- Firebase Auth `createUserWithEmailAndPassword`
- Set display name via `updateDisplayName`

**Dependencies:**
- `firebase_auth`

**Acceptance Criteria:**
- [ ] All fields validate on blur and on submit
- [ ] Passwords must match
- [ ] Password minimum 8 characters
- [ ] Successful registration creates account and navigates to Home
- [ ] "Email already in use" error handled
- [ ] "Weak password" error handled

---

### 2.5 Authentication — Forgot Password

**Design Reference:** `17_forgetpass.jpg`

**Description:** Password reset screen. User enters email to receive a reset link.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Email input field |
| Loading | Spinner on button |
| Success | Show "Reset email sent" confirmation |
| Error | Show error (user not found, etc.) |

**Business Requirements:**
- Email field with validation
- "Send Reset Link" button
- Firebase Auth `sendPasswordResetEmail`
- Success message with option to return to Login

**Dependencies:**
- `firebase_auth`

**Acceptance Criteria:**
- [ ] Email validates format
- [ ] Success shows confirmation message
- [ ] "User not found" error handled
- [ ] Back navigation to Login

---

### 2.6 Home

**Design Reference:** `05_home.jpg`

**Description:** Main dashboard screen. Features a navy header with greeting and search bar, category chips for property types, and a grid/list of featured properties. Accessible via the navigation drawer.

**UI States:**

| State | Behavior |
|---|---|
| Loading | Shimmer placeholders for featured properties |
| Success | Category chips + featured property cards |
| Empty | "No properties found" with illustration |
| Error | Retry button with error message |

**Business Requirements:**
- Navy gradient header with user greeting ("Hello, [Name]")
- Search bar (navigates to Property Search)
- Category chips: All, Apartment, Villa, Duplex, Studio, etc. (filterable)
- Featured properties section — fetched from `/api/recommendations/featured/list`
- Each property card shows: image, title, price, location, bedrooms, bathrooms, area
- Tap card → Property Details (future) or similar listing endpoint
- Favorite button on each card (heart icon)
- Pull-to-refresh

**Dependencies:**
- `firebase_auth` (user display name for greeting)
- Python AI Backend (`/api/recommendations/featured/list`)

**Acceptance Criteria:**
- [ ] Greeting shows user's display name
- [ ] Featured properties loaded from API
- [ ] Category chips filter the displayed properties
- [ ] Property cards render image, title, price, location, specs
- [ ] Favorite toggle works on each card
- [ ] Pull-to-refresh reloads data
- [ ] Loading shimmer displayed while fetching
- [ ] Error state with retry button

---

### 2.7 Navigation Drawer

**Design Reference:** `06_navigation_drawer.jpg`

**Description:** App-wide navigation drawer with navy gradient background, profile section, and menu items with gold accent icons.

**UI States:**

| State | Behavior |
|---|---|
| Default | Profile info + menu items + logout |

**Business Requirements:**
- **Profile section (top):** User photo (placeholder if none), display name, email
- **Menu items:** Home, Recommendations, Price Prediction, AI Chat, Favorites, Settings
- **Logout** button at bottom
- Active item highlighted with gold accent
- Drawer accessible via hamburger icon on Home and toolbar on other screens
- Drawer closes on item selection and navigates to the selected screen

**Dependencies:**
- `firebase_auth` (user profile data)
- `go_router` (navigation)

**Acceptance Criteria:**
- [ ] Profile section shows photo, name, email
- [ ] All menu items navigate to correct screens
- [ ] Active screen highlighted in drawer
- [ ] Logout clears session and navigates to Login
- [ ] Drawer closes on selection

---

### 2.8 Recommendations — Filters

**Design Reference:** `07_recommendation_filters.jpg`

**Description:** Filter screen for the AI recommendation system. Users select property preferences (type, location, price range, bedrooms, etc.) to get personalized recommendations.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Filter form with default/empty values |
| Validating | Minimum required filters checked |
| Submitting | Loading indicator |

**Business Requirements:**
- Property type selector (Apartment, Villa, Duplex, etc.)
- Location/City selector
- Price range (min/max sliders or text fields)
- Bedrooms count selector
- Bathrooms count selector
- Area range (min/max)
- "Search" button — gold gradient
- "Reset" option to clear filters
- Submits to `/api/recommendations/search` (POST)

**Dependencies:**
- Python AI Backend (`/api/recommendations/search`)

**Acceptance Criteria:**
- [ ] All filter fields functional
- [ ] At least one filter required before search
- [ ] Search navigates to Results screen with filter parameters
- [ ] Reset clears all filters to defaults

---

### 2.9 Recommendations — Results

**Design Reference:** `08_recommendation_results.jpg`

**Description:** Displays AI-recommended properties based on the user's filters. Shows a scrollable list of property cards with match scores.

**UI States:**

| State | Behavior |
|---|---|
| Loading | Shimmer placeholders |
| Success | List of recommendation cards with AI match scores |
| Empty | "No matching properties" with illustration |
| Error | Error message with retry |

**Business Requirements:**
- Display recommended properties as cards
- Each card: image, title, price, location, specs, AI match score (percentage)
- "Similar properties" link per card → fetches `/api/recommendations/similar/{id}`
- Favorite button on each card
- Pagination or "Load More" for large result sets
- Back navigation returns to Filters (preserving selections)

**Dependencies:**
- Python AI Backend (`/api/recommendations/search`, `/api/recommendations/similar/{id}`)

**Acceptance Criteria:**
- [ ] Results display with AI match scores
- [ ] Cards show all property information
- [ ] Favorite toggle works
- [ ] "Similar" fetches and displays related properties
- [ ] Empty state shown when no matches
- [ ] Error state with retry

---

### 2.10 Price Prediction — Input

**Design Reference:** `09_price_prediction.jpg`

**Description:** Form screen where users input property details to get an AI-powered price estimate. Uses the StackingRegressor model on the backend.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Empty prediction form |
| Validating | Field-level validation |
| Submitting | Loading overlay |

**Business Requirements:**
- Property type dropdown
- Location/City dropdown
- Number of bedrooms selector
- Number of bathrooms selector
- Area in square meters input
- Floor number input
- Finished/Semi-finished/Unfinished selector
- Additional features (parking, garden, pool — checkboxes)
- "Predict Price" button — gold gradient
- Submits to `POST /api/predict`

**Dependencies:**
- Python AI Backend (`/api/predict`)

**Acceptance Criteria:**
- [ ] All property attribute fields functional
- [ ] Required fields validated before submission
- [ ] Submit navigates to Results with prediction data
- [ ] Loading state during API call

---

### 2.11 Price Prediction — Results

**Design Reference:** `10_price_prediction_results.jpg`

**Description:** Displays the AI-predicted price with a visual breakdown. Shows the estimated price prominently with property details summary.

**UI States:**

| State | Behavior |
|---|---|
| Success | Predicted price displayed prominently + property summary |
| Error | Error message with option to go back and retry |

**Business Requirements:**
- Large predicted price display (formatted in EGP)
- Property details summary (what was submitted)
- Confidence indicator if available from API
- "Predict Another" button → returns to input screen
- "Share" option (future)

**Dependencies:**
- Price Prediction Cubit (receives data from input screen)

**Acceptance Criteria:**
- [ ] Predicted price displayed in large, formatted text
- [ ] Property summary matches submitted values
- [ ] "Predict Another" navigates back to input (cleared form)
- [ ] Price formatted with EGP currency

---

### 2.12 AI Chat

**Design Reference:** `11_ai_chat.png`

**Description:** Conversational AI assistant powered by Gemini/Groq. Chat bubble interface where users ask questions about Egyptian real estate.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Welcome message from AI + empty input |
| Messaging | User sends message, AI typing indicator, AI response appears |
| Error | Error message in chat bubble with retry option |

**Business Requirements:**
- Chat bubble UI (user bubbles right/gold, AI bubbles left/white)
- Text input bar at bottom with send button
- AI typing indicator while waiting for response
- Messages sent to `POST /api/chat`
- The AI chatbot has 6 integrated tools (search properties, predict prices, etc.)
- Chat history maintained within session
- Auto-scroll to latest message
- Support for Arabic and English messages

**Dependencies:**
- Python AI Backend (`/api/chat`)

**Acceptance Criteria:**
- [ ] User messages appear as right-aligned gold/navy bubbles
- [ ] AI responses appear as left-aligned white bubbles
- [ ] Typing indicator shown during API call
- [ ] Send button disabled when input is empty
- [ ] Auto-scroll to new messages
- [ ] Error responses shown as special error bubbles with retry
- [ ] Input supports multiline
- [ ] Arabic text renders correctly (RTL within bubbles)

---

### 2.13 Favorites

**Design Reference:** `12_favorites.png`

**Description:** Saved/favorited properties screen. Displays all properties the user has marked as favorites.

**UI States:**

| State | Behavior |
|---|---|
| Loading | Shimmer placeholders |
| Success | List of favorited property cards |
| Empty | "No favorites yet" with illustration and CTA |
| Error | Error message (if loading from backend) |

**Business Requirements:**
- Display favorited properties as cards (same card component as Home/Recommendations)
- Remove from favorites via heart icon toggle or swipe-to-delete
- **Persist favorites in Firestore** under `users/{uid}/favorites` — Firestore is the source of truth for authenticated users
- **No Hive** — do not introduce Hive for favorites; Firestore offline cache (`FirebaseFirestore.instance.settings`) handles basic offline availability
- Navigate to property details on card tap
- Clear in-memory favorites state on sign-out

**Dependencies:**
- `cloud_firestore` (Firestore persistence)
- Property card widget (shared with Home, Recommendations)

**Acceptance Criteria:**
- [ ] Favorites persist across app restarts (Firestore)
- [ ] Only authenticated user's favorites are accessible
- [ ] Remove animation on un-favorite
- [ ] Empty state with encouraging message
- [ ] Property cards consistent with other screens
- [ ] Favorites state cleared on sign-out

---

### 2.14 Settings

**Design Reference:** `13_settings.png`

**Description:** Settings hub with rounded white cards for each option. Includes profile management, language switching, and account actions.

**UI States:**

| State | Behavior |
|---|---|
| Default | List of settings tiles |

**Business Requirements:**
- **Settings tiles (white rounded cards with chevrons):**
  - Edit Profile → Edit Profile screen
  - Change Email → Change Email screen
  - Change Password → Change Password screen
  - Language (English/Arabic toggle)
  - About / Terms (future)
  - Delete Account (red text + icon, requires confirmation dialog)
  - Logout
- Each tile: icon (left), label, chevron (right)
- Delete Account shows confirmation dialog before proceeding

**Dependencies:**
- `firebase_auth` (account management)
- `SharedPreferences` (language preference)

**Acceptance Criteria:**
- [ ] All settings tiles navigate to correct screens
- [ ] Language toggle switches app locale immediately
- [ ] Delete Account shows confirmation dialog
- [ ] Delete Account removes Firebase user and navigates to Login
- [ ] Logout clears session and navigates to Login

---

### 2.15 Settings — Edit Profile

**Design Reference:** `16_edit_profile.png`

**Description:** Edit user profile information — display name and profile photo.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Pre-filled form with current profile data |
| Loading | Save button shows spinner |
| Success | Show success message, navigate back |
| Error | Show error message |

**Business Requirements:**
- Display name field (pre-filled with current Firebase Auth `displayName`)
- Profile photo (tap to change — camera/gallery picker) — optional
- **Email field displayed as read-only** (for reference; editing email uses the separate Change Email screen)
- **No phone number field** — not present in `16_edit_profile.png` or the Firebase Auth user model
- "Save" button — submits display name update and optional photo
- Updates `FirebaseAuth.currentUser.updateDisplayName()`
- Uploads photo to Firebase Storage if changed

**Dependencies:**
- `firebase_auth`
- `image_picker` (photo selection)

**Acceptance Criteria:**
- [ ] Current name pre-filled from Firebase Auth `displayName`
- [ ] Email shown as read-only
- [ ] No phone number field
- [ ] Profile photo changeable via image picker
- [ ] Save updates Firebase profile display name
- [ ] Photo upload saves to Firebase Storage and updates auth profile photo URL
- [ ] Success feedback shown

---

### 2.16 Settings — Change Email

**Design Reference:** `14_change_email.png`

**Description:** Change the user's email address. Requires current password for re-authentication.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Current email (read-only) + new email field + password field |
| Loading | Spinner |
| Success | Confirmation message |
| Error | Error message (wrong password, email in use) |

**Business Requirements:**
- Display current email (read-only)
- New email field with validation
- Current password field (for re-authentication)
- Firebase `reauthenticateWithCredential` → `verifyBeforeUpdateEmail`

**Dependencies:**
- `firebase_auth`

**Acceptance Criteria:**
- [ ] Current email displayed
- [ ] New email validated
- [ ] Re-authentication required
- [ ] Success message shown
- [ ] "Email already in use" error handled

---

### 2.17 Settings — Change Password

**Design Reference:** `15_change_password.png`

**Description:** Change the user's password. Requires current password for security.

**UI States:**

| State | Behavior |
|---|---|
| Initial | Current password + new password + confirm password |
| Loading | Spinner |
| Success | Confirmation message |
| Error | Error message (wrong current password, weak new password) |

**Business Requirements:**
- Current password field
- New password field (min 8 chars)
- Confirm new password field
- Firebase `reauthenticateWithCredential` → `updatePassword`

**Dependencies:**
- `firebase_auth`

**Acceptance Criteria:**
- [ ] Current password required
- [ ] New passwords must match
- [ ] Minimum 8 characters enforced
- [ ] Success message shown
- [ ] "Wrong password" error handled

---

## 3. Feature Dependency Map

```
                    ┌──────────┐
                    │  Splash  │
                    └────┬─────┘
                         │
              ┌──────────┼──────────┐
              ▼          ▼          ▼
        ┌──────────┐ ┌───────┐ ┌──────┐
        │Onboarding│ │ Login │ │ Home │
        └────┬─────┘ └───┬───┘ └──┬───┘
             │           │        │
             └─────►─────┘        │
                                  │
         ┌─────────┬──────────┬───┴────┬──────────┐
         ▼         ▼          ▼        ▼          ▼
    ┌─────────┐┌────────┐┌───────┐┌────────┐┌────────┐
    │Recommend.││ Price  ││AI Chat││Favorite││Settings│
    │ Filters  ││Predict ││       ││        ││        │
    └────┬─────┘└───┬────┘└───────┘└────────┘└───┬────┘
         ▼         ▼                              │
    ┌─────────┐┌────────┐           ┌─────┬───────┼──────┐
    │ Results ││Results ││           │     │       │      │
    └─────────┘└────────┘       Edit  Change  Change  Delete
                               Profile Email  Password Account
```

### Shared Dependencies

| Component | Used By |
|---|---|
| **Property Card widget** | Home, Recommendations Results, Favorites |
| **AppHeader widget** | All screens except Splash, Onboarding |
| **Auth Cubit** | Login, Register, Forgot Password, Settings (logout/delete) |
| **Favorites Cubit** | Home, Recommendations Results, Favorites |
| **Navigation Drawer** | All authenticated screens (via ShellRoute) |

---

## 4. API Integration Map

| Feature | Endpoint | Method | Notes |
|---|---|---|---|
| Home — Featured | `/api/recommendations/featured/list` | GET | Load on screen init |
| Recommendations — Search | `/api/recommendations/search` | POST / GET | POST with filter body |
| Recommendations — Similar | `/api/recommendations/similar/{id}` | GET | Per-card action |
| Recommendations — Details | `/api/recommendations/{id}` | GET | Single property detail |
| Recommendations — Batch | `/api/recommendations/batch` | POST | Multiple IDs at once |
| Price Prediction | `/api/predict` | POST | Form data → prediction |
| AI Chat | `/api/chat` | POST | Message → AI response |
| Health Check | `/api/health` | GET | App startup connectivity check |
