# Monster Meter 🧃⚡

A mobile app for Android that helps you track your daily Monster Energy drink consumption. Keep tabs on your caffeine intake, spending, and drinking habits!

## Features

- **Daily Statistics**: View your daily drink count, total caffeine intake, and spending
- **Quick Logging**: Add drinks with flavor, price, timestamp, and optional notes
- **Flavor Management**: Manage your Monster Energy flavors library
- **History & Statistics**: View all-time statistics and historical drink logs
- **Local Storage**: All data is stored locally using SQLite

## Database Structure

The app uses three main tables:

### Users Table
| Column   | Type | Description          |
|----------|------|----------------------|
| id       | int  | Primary key          |
| username | text | Username             |

### Flavors Table
| Column      | Type | Description               |
|-------------|------|---------------------------|
| id          | int  | Primary key               |
| name        | text | Flavor name               |
| ml          | int  | Volume in milliliters     |
| caffeine_mg | int  | Caffeine content in mg    |
| is_active   | bool | Active/inactive flag      |

### Logs Table
| Column     | Type | Description                    |
|------------|------|--------------------------------|
| id         | int  | Primary key                    |
| user_id    | int  | Foreign key to users           |
| flavor_id  | int  | Foreign key to flavors         |
| price_paid | real | Price paid for the drink       |
| timestamp  | text | Date and time of consumption   |
| notes      | text | Optional notes                 |

## Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite (via sqflite package)
- **Date Formatting**: intl package
- **Path Management**: path package

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

## Setup Instructions

### 1. Install Flutter

If you haven't already, install Flutter by following the official guide:
https://docs.flutter.dev/get-started/install

### 2. Clone/Navigate to the Project

```bash
cd /home/jean/Documents/Personal/projects/monster-meter
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Check Flutter Setup

```bash
flutter doctor
```

Make sure all checks pass (Android toolchain, Android Studio, etc.)

### 5. Connect Your Device or Start Emulator

For a physical device:
- Enable Developer Options and USB Debugging on your Android device
- Connect via USB

For an emulator:
- Open Android Studio > AVD Manager
- Create/start an Android Virtual Device

Verify your device is connected:
```bash
flutter devices
```

### 6. Run the App

```bash
flutter run
```

Or for a release build:
```bash
flutter run --release
```

## Building APK

To build a release APK:

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

To build an app bundle (for Play Store):

```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── database/
│   └── database_helper.dart           # SQLite database operations
├── models/
│   ├── user.dart                      # User model
│   ├── flavor.dart                    # Flavor model
│   ├── log.dart                       # Log model
│   └── log_with_flavor.dart          # Combined model for logs with flavor details
└── screens/
    ├── home_screen.dart               # Main screen with daily stats
    ├── add_drink_screen.dart          # Screen to log a new drink
    ├── history_screen.dart            # View all logs and statistics
    └── manage_flavors_screen.dart     # Manage flavor library
```

## Usage

### Adding a Drink

1. Tap the "Add Drink" button on the home screen
2. Select a flavor from the dropdown
3. Enter the price you paid
4. Optionally adjust the date/time
5. Add notes if desired
6. Tap "Save Drink"

### Managing Flavors

1. Tap the drink icon in the app bar
2. Add new flavors with the "Add Flavor" button
3. Edit, deactivate, or delete existing flavors using the menu (⋮)
4. Toggle visibility of inactive flavors with the eye icon

### Viewing History

1. Tap the history icon in the app bar
2. View all-time statistics at the top
3. Scroll through drinks grouped by date
4. Delete entries by tapping the delete icon

## Pre-loaded Flavors

The app comes with these popular Monster Energy flavors:

- Original (500ml, 160mg caffeine)
- Ultra White (500ml, 140mg caffeine)
- Ultra Fiesta (500ml, 140mg caffeine)
- Ultra Paradise (500ml, 140mg caffeine)
- Ultra Sunrise (500ml, 140mg caffeine)
- Pipeline Punch (500ml, 160mg caffeine)
- Mango Loco (500ml, 160mg caffeine)

## Customization

### Changing Theme Colors

Edit the theme in `lib/main.dart`:

```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF00FF00), // Change this color
  brightness: Brightness.dark,
),
```

### Adding More Flavors

You can add more default flavors in `lib/database/database_helper.dart` in the `_createDB` method.

## Contributing

This is a personal project, but feel free to fork it and customize it for your own use!

## License

This project is for personal use.

## Disclaimer

This app is not affiliated with Monster Energy. Monster Energy is a trademark of Monster Energy Company.

Remember to drink responsibly and be mindful of your caffeine intake! The FDA recommends a maximum of 400mg of caffeine per day for healthy adults.

---

Made with ❤️ and ⚡

