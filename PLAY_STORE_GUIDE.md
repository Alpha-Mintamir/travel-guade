# Play Store Publishing Guide for Travel Buddy

## What's Ready

- [x] Privacy Policy created (`PRIVACY_POLICY.md`)
- [x] Release signing configured (keystore generated)
- [x] Release build working (`app-release.aab` - 46.1MB)
- [x] ProGuard rules configured
- [x] Target SDK 34 (meets Play Store requirements)

## Important Files Location

| File | Location | Notes |
|------|----------|-------|
| **App Bundle** | `mobile/build/app/outputs/bundle/release/app-release.aab` | Upload this to Play Store |
| **Keystore** | `mobile/android/travel-buddy-keystore.jks` | **BACKUP THIS FILE!** |
| **Key Properties** | `mobile/android/key.properties` | Contains passwords |
| **Privacy Policy** | `PRIVACY_POLICY.md` | Host this online |

---

## Step-by-Step Play Console Guide

### Step 1: Create Google Play Developer Account

1. Go to https://play.google.com/console
2. Sign in with your Google account
3. Pay the **one-time $25 registration fee**
4. Complete account verification (may take 24-48 hours)

### Step 2: Host Your Privacy Policy

Your Privacy Policy must be accessible via a public URL. Options:

**Option A: GitHub Pages (Free)**
1. Your privacy policy is already at: `PRIVACY_POLICY.md`
2. Enable GitHub Pages in your repo settings
3. URL will be: `https://alpha-mintamir.github.io/travel-guade/PRIVACY_POLICY`

**Option B: Create a Simple Website**
1. Use Netlify, Vercel, or any hosting
2. Create a simple HTML page with your privacy policy

**Option C: Google Sites (Free)**
1. Go to sites.google.com
2. Create a new site
3. Add a page with your privacy policy content

### Step 3: Create App in Play Console

1. Click **"Create app"**
2. Fill in:
   - **App name**: Travel Buddy
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
3. Accept the declarations and create

### Step 4: Set Up Store Listing

Navigate to **Grow > Store presence > Main store listing**

#### App Details
- **App name**: Travel Buddy
- **Short description** (80 chars max):
  ```
  Find travel partners for Ethiopian adventures. Connect, chat & explore together!
  ```
- **Full description** (4000 chars max):
  ```
  Travel Buddy - Your Ethiopian Travel Companion

  Are you planning to visit the ancient churches of Lalibela? The stunning Simien Mountains? The historic castles of Gondar? Don't travel alone - find your perfect travel partner!

  🌍 DISCOVER TRAVEL PARTNERS
  Browse trips created by fellow travelers heading to the same destinations. Filter by location, travel style, budget, and dates to find your ideal match.

  ✈️ CREATE YOUR OWN TRIPS
  Planning a trip? Create a listing and let others join you! Share your destination, dates, budget level, and what kind of travel experience you're looking for.

  💬 CONNECT & COMMUNICATE
  Found an interesting trip? Send a request to join! Chat directly with trip creators through our built-in messaging system.

  📸 INSTAGRAM-STYLE FEED
  Beautiful trip cards with swipeable photos show you both the destination and your potential travel buddy.

  🔒 SAFE & SECURE
  - Verified user accounts
  - In-app messaging
  - Report and block features
  - No hidden fees

  FEATURES:
  • Browse trips by destination, style, or budget
  • Create and manage your own trips
  • Real-time chat with potential travel partners
  • Swipeable photo galleries for each trip
  • Push notifications for messages and requests
  • Dark mode support

  Popular Ethiopian Destinations:
  🏛️ Lalibela - Rock-hewn churches
  🏰 Gondar - Royal castles
  ⛰️ Simien Mountains - Stunning landscapes
  🌋 Danakil Depression - Otherworldly terrain
  🌿 Bale Mountains - Endemic wildlife
  🕌 Harar - Ancient walled city

  Travel Buddy makes solo travel social. Download now and start your Ethiopian adventure!
  ```

#### Graphics
You'll need:
- **App icon**: 512 x 512 PNG (use `mobile/assets/icon.png`)
- **Feature graphic**: 1024 x 500 PNG
- **Screenshots**: Minimum 2, up to 8 per device type
  - Phone: 16:9 or 9:16 aspect ratio
  - 7-inch tablet (optional)
  - 10-inch tablet (optional)

**Screenshot ideas:**
1. Home/Explore screen showing trip cards
2. Trip detail page
3. Create trip screen
4. Chat conversation
5. Profile screen

### Step 5: App Content (Content Rating)

Navigate to **Policy > App content**

#### Content Rating Questionnaire
1. Start the questionnaire
2. Select category: **Social/Communication**
3. Answer questions honestly:
   - User-generated content: **Yes** (trip posts, chat)
   - User interaction: **Yes** (messaging)
   - Location sharing: **No** (only destination names)
   - Personal information: **Yes** (profiles)

Expected rating: **Everyone** or **Teen**

#### Data Safety Form
This is CRITICAL. Fill out honestly:

| Data Type | Collected | Shared | Required |
|-----------|-----------|--------|----------|
| Name | Yes | Yes (with other users) | Yes |
| Email | Yes | No | Yes |
| Profile photo | Yes | Yes (with other users) | No |
| Photos | Yes | Yes (with other users) | No |
| Messages | Yes | Yes (with recipients) | No |

**Data Security:**
- Data encrypted in transit: **Yes** (HTTPS)
- Users can request deletion: **Yes**

#### Privacy Policy
- Enter your hosted Privacy Policy URL

#### Ads
- Select: **No, my app does not contain ads**

### Step 6: Release Your App

Navigate to **Release > Production**

1. Click **"Create new release"**
2. **App signing**: Let Google manage your signing key (recommended)
3. **Upload App Bundle**: 
   - Upload `mobile/build/app/outputs/bundle/release/app-release.aab`
4. **Release name**: 1.0.0
5. **Release notes**:
   ```
   Initial release of Travel Buddy!
   
   • Find travel partners for Ethiopian destinations
   • Create and share your trip plans
   • Connect through in-app messaging
   • Beautiful Instagram-style trip cards
   ```
6. Click **"Review release"**
7. Fix any errors/warnings shown
8. Click **"Start rollout to Production"**

### Step 7: Wait for Review

- Review typically takes **1-3 days** for new apps
- You'll receive email updates on review status
- If rejected, fix the issues and resubmit

---

## Troubleshooting Common Issues

### Rejection: "Broken functionality"
- Make sure your backend API is working
- Test all features before submitting

### Rejection: "Privacy Policy"
- Ensure your privacy policy URL is accessible
- Make sure it mentions all data you collect

### Rejection: "Metadata policy violation"
- Don't use trademarked terms
- Don't make false claims
- Don't use excessive keywords

---

## Backup Your Keystore!

**CRITICAL**: Back up these files securely:
- `mobile/android/travel-buddy-keystore.jks`
- `mobile/android/key.properties`

If you lose these, you **cannot update your app** on Play Store!

Recommended backup locations:
1. Google Drive (encrypted)
2. USB drive
3. Password manager

---

## Keystore Details (Save These!)

```
Keystore: travel-buddy-keystore.jks
Alias: travel-buddy-key
Password: TravelBuddy2026!
Validity: 10,000 days
```

---

## After Publishing

1. **Monitor reviews** and respond to user feedback
2. **Fix bugs** promptly and release updates
3. **Check vitals** for crashes and ANRs
4. **Respond to policy emails** from Google quickly

Good luck with your launch! 🚀
