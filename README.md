# Cyclfit - Complete Cycling Fitness App

Cyclfit is a comprehensive cycling fitness app built with Flutter that provides workout tracking, health monitoring, gamification, and blog features. This production-ready app includes real-time GPS tracking, health data visualization, challenge system, and offline capabilities.

## 🚴 Features

### Core Features
- **Workout Tracking**: Real-time GPS tracking with route visualization
- **Health Monitoring**: Track blood pressure, weight, heart rate, and more
- **Blog System**: Read cycling tips, training guides, and gear reviews
- **Gamification**: Challenges, achievements, and reward system
- **Authentication**: Supabase Auth with Google Sign-In support
- **Offline Mode**: Local SQLite database with sync capabilities

### Technical Features
- **Material Design 3**: Modern, responsive UI
- **State Management**: Provider pattern for scalable architecture
- **Local Database**: Drift ORM with SQLite for offline storage
- **Background Services**: Location tracking during workouts
- **Push Notifications**: Workout reminders and achievement alerts
- **Data Visualization**: Interactive charts with fl_chart
- **Map Integration**: OpenStreetMap with offline tile caching

## 🖼️ Screenshots

*Note: Add screenshots of your app here once you've customized the UI*

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd cyclfit_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate database code**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Supabase (Required for backend features)**
   - Create a Supabase project at https://supabase.com
   - Run the SQL in `supabase/schema.sql` to create tables and indexes.
   - Run the SQL in `supabase/policies.sql` to enable RLS and policies.
   - Update `lib/core/config/app_config.dart` with your Supabase URL and anon key:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```
   - In Supabase Dashboard → Authentication → Providers, enable Email/Password and Google (optional). Configure redirect URLs for Android (app link) and Web if applicable.
   - Important: Do not commit real keys to version control. Use env files or CI secrets.

5. **Set up Google Sign-In (Optional)**
   - Follow the [Google Sign-In setup guide](https://pub.dev/packages/google_sign_in)
   - Add your `google-services.json` to `android/app/`

6. **Configure Android permissions**
   The app requires these permissions (already configured in `android/app/src/main/AndroidManifest.xml`):
   - `ACCESS_FINE_LOCATION` - GPS tracking
   - `ACCESS_COARSE_LOCATION` - Location services
   - `INTERNET` - API calls and map tiles
   - `ACCESS_NETWORK_STATE` - Connectivity checks

### Running the App

#### Debug Mode
```bash
flutter run
```

#### Release Build
```bash
flutter build apk --release
```

The APK will be generated in `build/app/outputs/flutter-apk/`

## 📁 Project Structure

```
lib/
├── core/                   # Core functionality
│   ├── config/            # App configuration
│   ├── database/          # Database setup and tables
│   ├── router/            # Navigation routing
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── data/                  # Data layer
│   ├── datasources/       # API and local data sources
│   ├── models/            # Data models
│   └── repositories/      # Data repositories
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── blog/              # Blog and articles
│   ├── challenges/        # Challenges and achievements
│   ├── health/            # Health metrics tracking
│   ├── home/              # Dashboard and home
│   ├── profile/           # User profile and settings
│   └── workout/           # Workout tracking
├── shared/                # Shared components
│   ├── providers/         # State management
│   ├── services/          # App services
│   └── widgets/           # Reusable widgets
└── main.dart              # App entry point
```

## 🗄️ Database Schema

The app uses Drift ORM with SQLite for local storage:

- **workout_sessions**: Store workout data and metrics
- **route_points**: GPS coordinates for workout routes
- **health_metrics**: User health data (weight, BP, etc.)
- **user_profiles**: User information and preferences
- **challenges**: Available challenges and goals
- **achievements**: Unlockable badges and rewards
- **articles**: Blog posts and cached content

## ⚙️ Configuration

### App Configuration
Edit `lib/core/config/app_config.dart` to customize:
- Supabase credentials
- Map settings
- Location accuracy
- Gamification points
- Cache settings

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to change:
- Color scheme
- Typography
- Component styles
- Dark/light themes

## 🧭 Usage Guide

### Starting a Workout
1. Tap "Start Workout" on the home screen
2. Grant location permissions when prompted
3. The app will track your route, speed, and distance
4. Use controls to pause/resume/stop the workout

### Health Tracking
1. Navigate to the Health tab
2. Add metrics like weight, blood pressure, heart rate
3. View trends and progress charts
4. Set health goals and track progress

### Challenges
1. Browse available challenges in the Challenges tab
2. Join challenges that match your fitness level
3. Track progress and earn rewards
4. Unlock achievements for milestones

### Blog Reading
1. Browse articles in the Blog tab
2. Articles are cached for offline reading
3. Search by category or keywords
4. Share interesting articles

## 🔌 API Integration

### Supabase Setup
1. Create tables in your Supabase database:
   ```sql
   -- Users table (handled by Supabase Auth)
   -- Additional tables for syncing local data
   CREATE TABLE public.workout_sessions (
     id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id uuid REFERENCES auth.users NOT NULL,
     start_time timestamptz NOT NULL,
     end_time timestamptz,
     distance real DEFAULT 0,
     duration integer DEFAULT 0,
     created_at timestamptz DEFAULT now()
   );
   ```

2. Set up Row Level Security (RLS) policies (see `supabase/policies.sql`).
3. Configure authentication providers (enable Email/Password, optionally Google). Add authorized redirect URLs.

### Health Data Integration
The app supports integration with device health apps:
- Apple Health (iOS)
- Google Fit (Android)
- Manual data entry

## ✅ Testing

### Run Tests
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test test/integration/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Deployment

### Android Deployment
1. Generate signing key:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Configure `android/key.properties`

3. Build release APK:
   ```bash
   flutter build apk --release
   ```

4. Or build an App Bundle for Play Store:
   ```bash
   flutter build appbundle --release
   ```

### Google Play Store
1. Create app listing in Google Play Console
2. Upload APK or use App Bundle
3. Complete store listing with screenshots and descriptions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m 'Add some feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛟 Support

### Common Issues

**Q: App crashes on startup**
A: Check if you've configured Supabase credentials in `app_config.dart`

**Q: Location not working**
A: Ensure location permissions are granted and GPS is enabled

**Q: Build errors**
A: Run `flutter clean` and `flutter pub get`, then rebuild

**Q: Database errors**
A: Run the build runner: `flutter packages pub run build_runner build --delete-conflicting-outputs`

### Getting Help
- Create an issue in the GitHub repository
- Check the Flutter documentation
- Review the code comments for implementation details

## ��� Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend services
- OpenStreetMap for map data
- All the open-source package contributors

---

**Happy Cycling! ���‍♂️���‍♀️**
