# Supabase Setup Guide for Life Growth App

This guide will help you set up Supabase for your Life Growth Flutter app.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Flutter development environment set up

## Step 1: Create a New Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Fill in your project details:
   - **Name**: Life Growth App (or any name you prefer)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose the region closest to your users
5. Click "Create new project"
6. Wait for the project to be set up (this may take a few minutes)

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** > **API**
2. Copy the following values:
   - **Project URL** (something like `https://your-project-id.supabase.co`)
   - **Project API Key** (anon/public key)

## Step 3: Configure Your Flutter App

1. Open `lib/config/supabase_config.dart` in your Flutter project
2. Replace the placeholder values with your actual credentials:

```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'your-anon-key-here';
```

**Important**: Never commit your actual API keys to version control. Consider using environment variables or a config file that's ignored by git.

## Step 4: Set Up the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of `supabase_schema.sql` from your project root
4. Paste it into the SQL editor
5. Click "Run" to execute the schema

This will create all the necessary tables:
- `tasks` - For managing user tasks
- `habits` - For tracking user habits
- `habit_tracking` - For daily habit completion tracking
- `health_data` - For storing health metrics
- `user_profiles` - For additional user information

## Step 5: Configure Authentication

1. In your Supabase dashboard, go to **Authentication** > **Settings**
2. Configure your authentication settings:
   - **Site URL**: Set this to your app's URL (for development, you can use `http://localhost:3000`)
   - **Redirect URLs**: Add any URLs where users should be redirected after authentication

### Email Templates (Optional)

You can customize the email templates for:
- Email confirmation
- Password reset
- Email change confirmation

Go to **Authentication** > **Email Templates** to customize these.

## Step 6: Test Your Setup

1. Run your Flutter app: `flutter run`
2. Try creating a new account
3. Check your Supabase dashboard to see if:
   - The user appears in **Authentication** > **Users**
   - A user profile is created in the `user_profiles` table
   - You can create and view tasks, habits, etc.

## Step 7: Row Level Security (RLS)

The schema automatically sets up Row Level Security policies to ensure:
- Users can only access their own data
- Data is properly isolated between users
- Security is enforced at the database level

You can view and modify these policies in **Authentication** > **Policies**.

## Environment Variables (Recommended)

For production apps, consider using environment variables:

1. Create a `.env` file in your project root (add this to `.gitignore`)
2. Add your credentials:
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

3. Use a package like `flutter_dotenv` to load these values

## Troubleshooting

### Common Issues:

1. **"Invalid API key"**: Double-check that you copied the anon/public key, not the service role key
2. **"Cross-origin request blocked"**: Make sure your Site URL is configured correctly
3. **"Row Level Security policy violation"**: Check that your RLS policies are set up correctly
4. **Database connection issues**: Verify your project URL is correct

### Getting Help:

- Check the [Supabase Documentation](https://supabase.com/docs)
- Visit the [Supabase Community](https://github.com/supabase/supabase/discussions)
- Check the Flutter Supabase package documentation

## Next Steps

Once your Supabase setup is complete, you can:

1. Customize the database schema for your specific needs
2. Add more authentication providers (Google, Apple, etc.)
3. Set up real-time subscriptions for live data updates
4. Configure storage for file uploads (profile pictures, etc.)
5. Set up database functions for complex operations

## Security Best Practices

1. Never expose your service role key in client-side code
2. Always use Row Level Security policies
3. Regularly rotate your API keys
4. Use HTTPS in production
5. Validate and sanitize all user inputs
6. Monitor your database for unusual activity

Your Life Growth app is now ready to use Supabase for backend services!
