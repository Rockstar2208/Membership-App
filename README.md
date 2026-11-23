# Membership App

A Flutter app where users sign up, choose a membership tier (Starter, Plus or Premium) and upgrade it later. Everything runs locally: sign-in is simulated by email, and data is stored with SharedPreferences. There is no backend.

## Setup

Requirements: Flutter 3.38 or later (built with 3.44).

```bash
flutter pub get
flutter run
```

Run the tests:

```bash
flutter test
```

## Test accounts

Sign in with any of these emails. There are no passwords.

| Email | Tier |
| --- | --- |
| naledi.mokoena@example.com | Starter |
| lerato.nkosi@example.com | Starter |
| thabo.dlamini@example.com | Plus |
| sipho.khumalo@example.com | Plus |
| aisha.jacobs@example.com | Premium |

## How it works

- **Data:** `assets/data/users.json` is copied into SharedPreferences on first launch only. A `seeded` flag stops it from being copied again, so deleted profiles never come back. `assets/data/memberships.json` is read-only and is loaded from assets on every launch.
- **State:** `AuthProvider` (Provider / `ChangeNotifier`) holds the signed-in user, their membership, their features and the tiers they can upgrade to. All three tabs listen to it, so an upgrade updates them right away.
- **Storage:** `MembershipRepository` keeps every profile in one JSON list, so each user's membership is saved separately. The open session (`currentUserEmail`) is removed on sign-out.
- **Features:** each feature in `memberships.json` is an object with an `id` and a `name`, parsed into a `Feature` model. The name is shown on screen; the id is used as a widget key and to pick each feature's icon. Features are not cumulative: each tier shows exactly the features listed for it (for example, Plus does not include Starter Guides).
- **Upgrade rules:** tiers are ordered by their position in `memberships.json` (Starter, Plus, Premium). Only higher tiers are shown as upgrades.

```
lib/
  main.dart                       app entry; shows sign-in or tabs
  models/                         Feature, Membership, UserProfile
  services/membership_repository  JSON assets + SharedPreferences
  providers/auth_provider         Provider state
  screens/                        sign in, sign up, tab shell, feature placeholder
  screens/tabs/                   Home, Membership, Upgrade Membership
```

## Steps to verify the main flows

1. **Tier features:** Sign in as `naledi.mokoena@example.com` (Starter), `thabo.dlamini@example.com` (Plus) and `aisha.jacobs@example.com` (Premium). Sign out between each one using the menu at the top right. The Home and Membership tabs show different features for each: Starter has Browse Catalogue and Starter Guides, Plus has Browse Catalogue and Member Offers, and Premium has Browse Catalogue and Priority Support.
2. **Sign up:** On the sign-in screen tap *Sign up*. Enter a name and a new email and choose a tier. You are signed in on that tier. Signing up again with an existing email (in any letter case) shows an error.
3. **Upgrade:** Sign in as `naledi.mokoena@example.com`, open *Upgrade* and choose *Upgrade to Plus*, then confirm. Home, Membership and Upgrade update straight away, and Upgrade now offers only Premium. As `aisha.jacobs@example.com`, the Upgrade tab says you are on the highest tier.
4. **Persistence:** After upgrading, sign out and fully close the app. Reopen it, sign in as `naledi.mokoena@example.com` again, and the Plus membership is still there. `lerato.nkosi@example.com` is still on Starter.
5. **Deletion:** Sign in as `lerato.nkosi@example.com`, open the menu and choose *Delete profile*, then confirm. You go back to sign-in. Restart the app: `lerato.nkosi@example.com` can no longer sign in, but `thabo.dlamini@example.com` still can. Lerato must sign up again to get a new profile.

To start over from scratch, uninstall the app or clear its storage.
