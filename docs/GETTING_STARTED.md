# Run FoodSwift locally

[Back to the project overview](../README.md)

FoodSwift connects directly to Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging. Bring your own Firebase project; the generated client configuration and hosted data are not included in this repository.

## 1. Prepare the Android toolchain

- Install Flutter with a bundled Dart SDK that satisfies **`>=3.8.0 <4.0.0`**, as declared in `pubspec.yaml`. The lockfile also requires Flutter `>=3.27.0`; both constraints must be satisfied.
- Set up Android Studio, a compatible JDK, and an Android device or emulator with Google Play services.
- The Android project specifies **compile/target SDK 35** and **NDK `27.0.12077973`**. Its minimum SDK comes from Flutter's `flutter.minSdkVersion`.
- Install the [Firebase CLI](https://firebase.google.com/docs/cli) and make sure `firebase` is on your PATH.

```bash
flutter doctor
git clone https://github.com/ALMAFLEHI/FoodSwift.git
cd FoodSwift
flutter pub get
```

Only the **Android runner** is checked in. iOS, web, Windows, macOS, and Linux runner directories are absent; additional platforms need their own implementation and verification.

## 2. Connect your Firebase project

Create or select a project in the [Firebase Console](https://console.firebase.google.com/). Then run:

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

In the configuration workflow, explicitly select **your own Firebase project** and **Android**. The checked-in `firebase.json` contains the original project's identifiers; regenerate it for your environment. Keep the Android package consistent with `com.example.foodswiftv2`, or update the Android application ID and Firebase registration together.

Confirm that these files now exist:

```text
lib/firebase_options.dart
android/app/google-services.json
```

`lib/main.dart` imports `firebase_options.dart`, and the Android Gradle project applies the Google Services plugin. Both files are excluded by `.gitignore`. See the official [FlutterFire setup guide](https://firebase.google.com/docs/flutter/setup) for configuration details.

In Firebase:

1. Enable **Authentication → Email/Password** and **Google** sign-in.
2. For Google sign-in on Android, add the signing certificate's **SHA-1 fingerprint** to the registered Android app, then refresh its configuration. Follow [Firebase's federated sign-in setup](https://firebase.google.com/docs/auth/flutter/federated-auth).
3. Create a **Cloud Firestore** database and configure access rules for the accounts and roles you intend to test. This repository does not include Firestore rules or an index deployment file.
4. Populate restaurant and menu documents using the schema below.

Firebase Storage is not used by the checked-in client; menu images and restaurant logos are loaded from URL fields.

## 3. Create an account profile and menu data

Email/password login reads **`users/{Firebase Authentication UID}`**. After creating an Authentication account, create a document with that exact UID as its ID:

```json
{
  "email": "student@example.com",
  "role": "student"
}
```

Use `role: "admin"` for the admin route. Other roles follow the customer menu route; a separate staff order-processing screen is not implemented. The login screen's Google sign-in flow creates a missing profile automatically with role `user`.

**Registration caveat:** email registration creates an Authentication account but currently does not create its Firestore profile. The next email/password login will report “User profile not found” until `users/{uid}` exists. Sample user documents created by `SampleDataGenerator` use generated document IDs and do not create Authentication accounts, so they are not login credentials.

### Firestore collections

These names and fields match the checked-in client. `Timestamp` means a native Firestore timestamp, not a string.

| Collection | Fields used by the client |
| --- | --- |
| `users/{uid}` | `email` and `role` as strings. The model accepts an optional legacy `password` field; omit it and keep credentials in Firebase Authentication. |
| `restaurants/{id}` | `name`, `description`, `location`, `logoUrl` as strings. The document ID is the restaurant ID. |
| `menu/{id}` | `dishName`, `restaurantId`, `restaurantName`, `foodType`, `imageUrl` as strings; `price` as a number. The document ID is the item ID. |
| `menuItems/{id}` | The same item fields as `menu`; this is the separate collection currently used by admin tools and sample data. |
| `orders/{id}` | `userId`, `dishName`, `restaurantId`, `restaurantName`, `foodType`, `imageUrl`, `spiceLevel`, `portionSize`, `notes`, `status` as strings; `price` as a number; `timestamp` as a `Timestamp`. |
| `feedbacks/{id}` | `userId`, `type`, `message` as strings; `timestamp` as a `Timestamp`. |
| `complaints/{id}` | `complaintId`, `userId`, `userName`, `orderId`, `subject`, `description`, `status`, `priority` as strings; `createdAt` as a `Timestamp`; optional `adminResponse` string and `resolvedAt` `Timestamp`. The admin list query also orders by `timestamp`. |

The menu's cuisine filters use the exact values **`Malaysian`**, **`Indian`**, **`Chinese`**, and **`Western`**. Link each item's `restaurantId` to an existing restaurant document ID.

**Menu collection caveat:** the customer menu queries `menu`, while admin editing and the sample generator use `menuItems`. They do not synchronize. For a local demonstration with unchanged source, populate both collections consistently; a shared collection should be established before relying on admin edits to update the customer menu.

The order history query filters `orders` by `userId` and sorts by `timestamp` descending. If Firestore requests a composite index, create the index indicated by its diagnostic link. New orders start with status `preparing`. The history screen streams changes to the user's order documents.

## 4. Run and build

```bash
flutter devices
flutter run -d <device-id>
flutter build apk
```

Replace `<device-id>` with the Android device ID shown by `flutter devices`. The current release build configuration uses the debug signing configuration; configure release signing before distributing an APK as a release.

## Current implementation notes

- **Admin provider wiring:** `AdminDashboard` uses the `provider` package's `AdminProvider`, but `main.dart` currently installs only Riverpod's `ProviderScope`. A `ChangeNotifierProvider<AdminProvider>` ancestor must be added before that dashboard can run correctly.
- **Dashboard metrics:** order counts and summed order prices are computed from Firestore records. The average-rating calculation is a placeholder, and the “popular dishes” list takes five menu documents without ranking them by sales. Treat these as development UI.
- **Notifications:** `main.dart` requests FCM permission, obtains a token, and displays incoming foreground Android notifications locally. A backend that sends messages when an order becomes ready is not included.
- **Cart integration:** cart editing, totals, and submission code are present, but the menu does not call `CartController.addItem`. The current menu-to-customization path submits an order directly to Firestore; connecting it to the cart remains implementation work.
- **Order processing:** the client submits orders and streams their stored status. Scheduled pickup times, payments, and a dedicated staff status-update workflow are not implemented in the checked-in source.
- **Access control:** role-based navigation is client-side. Firestore rules and privileged backend operations must enforce the intended permissions in your Firebase environment.

## Development checks

```bash
flutter analyze
flutter test
```

Generate Firebase configuration before running these commands. The existing `test/widget_test.dart` is the default counter-app smoke test and does not match FoodSwift's screens or Firebase initialization. It needs replacement with app-specific tests; this repository does not establish a passing application test suite.

For the implementation, start with [`lib/main.dart`](../lib/main.dart), [`lib/app/router.dart`](../lib/app/router.dart), [`lib/features/`](../lib/features/), and [`lib/providers/admin_provider.dart`](../lib/providers/admin_provider.dart).
