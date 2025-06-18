# Environment Variables Setup Guide

This guide explains how to set up environment variables for your Life Growth Flutter app using the `.env` file approach.

## 🔧 What's Been Set Up

Your app now uses environment variables to securely store Supabase credentials instead of hardcoding them in the source code.

### Files Created/Modified:

1. **`.env`** - Contains your actual environment variables (already configured with your Supabase credentials)
2. **`.env.example`** - Template file showing the required environment variables
3. **`.gitignore`** - Updated to exclude `.env` files from version control
4. **`pubspec.yaml`** - Added `flutter_dotenv` dependency and `.env` asset
5. **`lib/config/supabase_config.dart`** - Updated to read from environment variables
6. **`lib/main.dart`** - Updated to load environment variables on app startup

## 🔐 Security Benefits

- ✅ **No hardcoded credentials** in source code
- ✅ **Credentials excluded from version control** (git)
- ✅ **Easy to manage different environments** (dev, staging, production)
- ✅ **Secure credential sharing** using `.env.example` template
- ✅ **Runtime validation** of required environment variables

## 📁 File Structure

```
your-project/
├── .env                    # Your actual credentials (not in git)
├── .env.example           # Template file (safe to commit)
├── .gitignore            # Updated to exclude .env files
├── lib/
│   ├── config/
│   │   └── supabase_config.dart  # Reads from environment variables
│   └── main.dart         # Loads .env file on startup
└── pubspec.yaml          # Added flutter_dotenv dependency
```

## 🚀 How It Works

1. **App Startup**: `main.dart` loads the `.env` file using `flutter_dotenv`
2. **Configuration**: `SupabaseConfig` reads credentials from environment variables
3. **Validation**: App checks if required variables are set and shows error if missing
4. **Initialization**: Supabase is initialized with the loaded credentials

## 🔧 Your Current Configuration

Your `.env` file is already configured with your Supabase credentials:

```env
SUPABASE_URL=https://govrbtxwbfuzdjhabzts.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ENVIRONMENT=development
APP_VERSION=1.0.0
```

## 🔄 For Different Environments

### Development
Use the current `.env` file for development.

### Staging/Production
Create separate `.env` files:

1. **`.env.staging`**
```env
SUPABASE_URL=https://your-staging-project.supabase.co
SUPABASE_ANON_KEY=your-staging-anon-key
ENVIRONMENT=staging
```

2. **`.env.production`**
```env
SUPABASE_URL=https://your-production-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
ENVIRONMENT=production
```

Then load the appropriate file in `main.dart`:
```dart
await dotenv.load(fileName: ".env.production");
```

## 🛠️ Adding New Environment Variables

1. **Add to `.env`**:
```env
NEW_VARIABLE=your_value_here
```

2. **Add to `.env.example`**:
```env
NEW_VARIABLE=example_value_or_description
```

3. **Use in your code**:
```dart
String newValue = dotenv.env['NEW_VARIABLE'] ?? 'default_value';
```

## 🔍 Troubleshooting

### Error: "Supabase credentials not found in environment variables"

**Cause**: The `.env` file is missing or environment variables are not set.

**Solution**:
1. Ensure `.env` file exists in your project root
2. Check that `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set in `.env`
3. Verify the `.env` file is listed in `pubspec.yaml` assets
4. Run `flutter clean` and `flutter pub get`

### Error: "Unable to load asset: .env"

**Cause**: The `.env` file is not included in the app bundle.

**Solution**:
1. Check `pubspec.yaml` has `.env` listed under assets
2. Ensure proper indentation in `pubspec.yaml`
3. Run `flutter clean` and `flutter pub get`

### Environment variables not updating

**Solution**:
1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Restart the app

## 🔒 Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use different credentials** for different environments
3. **Regularly rotate API keys** in production
4. **Use the anon key**, not the service role key in client apps
5. **Validate environment variables** at app startup
6. **Use HTTPS** for all API endpoints

## 📝 Team Collaboration

When sharing your project:

1. **Share `.env.example`** (safe template)
2. **Don't share `.env`** (contains actual credentials)
3. **Document required variables** in README
4. **Provide setup instructions** for new team members

New team members should:
1. Copy `.env.example` to `.env`
2. Fill in their own Supabase credentials
3. Follow the setup guide

## ✅ Verification

To verify everything is working:

1. **Run the app**: `flutter run`
2. **Check for errors**: No configuration errors should appear
3. **Test authentication**: Try signing up/signing in
4. **Check Supabase dashboard**: Verify users are created

Your app is now securely configured with environment variables! 🎉
