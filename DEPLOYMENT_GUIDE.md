# Cyclfit Deployment Guide

This guide will help you deploy the Cyclfit app to production.

## ��� Quick Start

### 1. Initial Setup
```bash
# Clone and setup the project
git clone <repository-url>
cd cyclfit_app
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Configure Backend Services

#### Supabase Setup (Required)
1. Create a Supabase project at https://supabase.com
2. Create the following tables (you can run `supabase/schema.sql`):

```sql
-- Workout Sessions (for syncing with mobile)
CREATE TABLE public.workout_sessions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users NOT NULL,
  start_time timestamptz NOT NULL,
  end_time timestamptz,
  distance real DEFAULT 0,
  duration integer DEFAULT 0,
  average_speed real DEFAULT 0,
  max_speed real DEFAULT 0,
  calories real DEFAULT 0,
  elevation real DEFAULT 0,
  average_heart_rate integer,
  max_heart_rate integer,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Health Metrics
CREATE TABLE public.health_metrics (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users NOT NULL,
  metric_type text NOT NULL,
  value real NOT NULL,
  secondary_value real,
  unit text NOT NULL,
  notes text,
  recorded_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Blog Articles
CREATE TABLE public.articles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  content text NOT NULL,
  excerpt text,
  author text NOT NULL,
  category text NOT NULL,
  featured_image_url text,
  tags text[],
  is_published boolean DEFAULT false,
  publish_date timestamptz NOT NULL,
  read_time integer,
  view_count integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

3. Set up Row Level Security (RLS) (you can run `supabase/policies.sql`):

```sql
-- Enable RLS
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.articles ENABLE ROW LEVEL SECURITY;

-- Workout sessions policies
CREATE POLICY "Users can view own workout sessions" ON public.workout_sessions
  FOR SELECT USING (auth.uid() = user_id);
  
CREATE POLICY "Users can insert own workout sessions" ON public.workout_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
  
CREATE POLICY "Users can update own workout sessions" ON public.workout_sessions
  FOR UPDATE USING (auth.uid() = user_id);

-- Health metrics policies
CREATE POLICY "Users can view own health metrics" ON public.health_metrics
  FOR SELECT USING (auth.uid() = user_id);
  
CREATE POLICY "Users can insert own health metrics" ON public.health_metrics
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Articles policies (public read, admin write)
CREATE POLICY "Anyone can view published articles" ON public.articles
  FOR SELECT USING (is_published = true);
```

4. Update `lib/core/config/app_config.dart`:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_PROJECT_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Configure Authentication

#### Google Sign-In Setup
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable Google Identity Services (OAuth)
4. Create OAuth 2.0 credentials
5. Download `google-services.json` and place in `android/app/`
6. Add SHA1 fingerprint for release builds (for Android Google Sign-In):
```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

### 4. Build for Production

#### Android Release Build
1. Generate upload keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.cyclfit"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

4. Build release APK:
```bash
flutter build apk --release
```

5. Or build App Bundle for Play Store:
```bash
flutter build appbundle --release
```

## ��� Google Play Store Deployment

### 1. Prepare Store Assets
- App icon (512x512 PNG)
- Feature graphic (1024x500)
- Screenshots (at least 2, max 8)
- Short description (80 characters)
- Full description (4000 characters)

### 2. Upload to Play Console
1. Create new app in Google Play Console
2. Upload AAB file from `build/app/outputs/bundle/release/`
3. Fill out store listing
4. Set content rating
5. Configure pricing and distribution
6. Submit for review

### 3. Release Management
- Use internal testing first
- Graduate to closed testing with testers
- Open testing for broader audience
- Production release when ready

## ��� Configuration Checklist

### Required Configuration
- [ ] Supabase URL and anon key
- [ ] Database tables created
- [ ] RLS policies configured
- [ ] Google Sign-In configured (optional)
- [ ] Android permissions in manifest
- [ ] Release signing configured

### Optional Configuration
- [ ] Firebase Analytics
- [ ] Crashlytics
- [ ] Push notifications
- [ ] Deep linking
- [ ] App indexing

## ��� Security Considerations

### API Keys
- Never commit API keys to version control
- Use environment variables or secure storage
- Rotate keys regularly
 - In this repo, update `lib/core/config/app_config.dart` locally but avoid committing real keys.

### Database Security
- Always use RLS with Supabase
- Validate all user inputs
- Implement rate limiting

### App Security
- Enable code obfuscation for release builds
- Use HTTPS for all network requests
- Validate certificates

## ��� Monitoring and Analytics

### Essential Metrics
- Active users (DAU/MAU)
- Workout completion rates
- Feature adoption
- Crash rates
- Performance metrics

### Tools
- Google Analytics for Firebase
- Crashlytics for crash reporting
- Supabase dashboard for backend metrics

## ��� CI/CD Pipeline

### GitHub Actions Example
```yaml
name: Build and Deploy
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-java@v1
      with:
        java-version: '12.x'
    - uses: subosito/flutter-action@v1
      with:
        flutter-version: '3.9.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v2
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## ��� Troubleshooting

### Common Issues
1. **Build failures**: Run `flutter clean` and `flutter pub get`
2. **Location permissions**: Check Android manifest
3. **Supabase connection**: Verify URL and keys
4. **Google Sign-In**: Ensure SHA1 fingerprint is correct

### Performance Optimization
- Enable R8 code shrinking
- Use ProGuard rules for release builds
- Optimize images and assets
- Implement lazy loading

## ��� Post-Deployment

### User Feedback
- Monitor app store reviews
- Implement in-app feedback
- Track user behavior analytics

### Updates
- Regular security updates
- Feature improvements based on usage
- Bug fixes and performance optimizations

### Maintenance
- Database cleanup and optimization
- API endpoint monitoring
- User data backup strategies

---

This deployment guide ensures your Cyclfit app is production-ready with proper security, monitoring, and maintenance procedures.
