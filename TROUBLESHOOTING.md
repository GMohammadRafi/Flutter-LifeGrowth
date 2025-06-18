# Troubleshooting Guide - Task Management System

## 🚨 Foreign Key Constraint Error

### Error Message:

```
Error: PostgrestException(message: insert or update on table "task_completions" violates foreign key constraint "task_completions_task_id_fkey", code: 23503, details: Key is not present in table "tasks"., hint: null)
```

### Root Cause:

This error occurs when the `task_completions` table is trying to reference a task ID that doesn't exist in the `tasks` table, or when there's a mismatch between table names in the foreign key constraints.

### Solution:

#### Step 1: Run the Database Migration Fix

1. Open your Supabase dashboard
2. Go to **SQL Editor**
3. Copy and paste the entire contents of `fix_database_migration.sql`
4. Click **Run** to execute the migration

This script will:

- ✅ Update your existing `tasks` table structure
- ✅ Create `categories` and `schedule_types` tables
- ✅ Drop and recreate `task_completions` with correct foreign keys
- ✅ Set up proper RLS policies
- ✅ Create necessary indexes

#### Step 2: Verify Tables Structure

After running the migration, verify these tables exist:

**tasks table should have:**

- `id` (UUID, primary key)
- `user_id` (UUID, foreign key to auth.users)
- `name` (TEXT, required)
- `category_id` (UUID, foreign key to categories)
- `schedule_type_id` (UUID, foreign key to schedule_types)
- `due_date` (DATE, optional)
- `notes` (TEXT, optional)
- `is_active` (BOOLEAN, default true)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

**task_completions table should have:**

- `id` (UUID, primary key)
- `task_id` (UUID, foreign key to **tasks.id**)
- `completion_date` (DATE)
- `is_completed` (BOOLEAN, default true)
- `created_at` (TIMESTAMPTZ)

#### Step 3: Test the Fix

1. Hot reload your Flutter app (`r` in terminal)
2. Try creating a new task
3. Try marking the task as complete
4. The error should be resolved

## 🚨 Row Level Security (RLS) Policy Error

### Error Message:

```
Error: PostgrestException(message: new row violates row-level security policy for table "task_completions", code: 42501, details: Forbidden, hint: null)
```

### Root Cause:

This error occurs when the RLS policies for `task_completions` are too restrictive or there's an issue with the policy logic that prevents inserting completion records.

### Solution:

#### Step 1: Run the RLS Fix Script

1. Open your Supabase dashboard
2. Go to **SQL Editor**
3. Copy and paste the entire contents of `fix_rls_policies.sql`
4. Click **Run** to execute the fix

#### Step 2: If Still Having Issues - Debug Script

1. Copy and paste the contents of `debug_rls_issue.sql`
2. Run it to get detailed information about the RLS setup
3. This script temporarily creates more permissive policies for testing

#### Step 3: Test the Fix

1. Hot reload your Flutter app (`r` in terminal)
2. Try creating a new task
3. Try marking the task as complete
4. The RLS error should be resolved

#### Step 4: Verify User Authentication

Make sure you're properly logged in:

- Check that `auth.uid()` returns a valid user ID
- Verify the task belongs to the authenticated user
- Ensure the user session is active

## 🔍 Other Common Issues

### Issue: "You must initialize the supabase instance"

**Solution:** This happens in tests. The main app initializes Supabase properly, but tests need mock setup.

### Issue: "RLS policy violation"

**Solution:** Ensure user is authenticated before accessing tasks. Check that RLS policies are properly set up.

### Issue: Categories/Schedule Types not loading

**Solution:**

1. Verify the tables exist in Supabase
2. Check that default data was inserted
3. Ensure RLS policies allow reading these tables

### Issue: Tasks not appearing after creation

**Solution:**

1. Check that `is_active` is set to `true`
2. Verify the user_id matches the authenticated user
3. Check RLS policies for the tasks table

## 🛠️ Manual Verification Steps

### Check Foreign Key Constraints:

```sql
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'task_completions';
```

### Check Table Structure:

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'tasks'
ORDER BY ordinal_position;
```

### Check RLS Policies:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('tasks', 'task_completions');
```

## 📞 Need More Help?

If you're still experiencing issues:

1. **Check Supabase Logs:** Go to Supabase Dashboard > Logs to see detailed error messages
2. **Verify Authentication:** Ensure user is properly logged in
3. **Check Network:** Verify internet connection and Supabase URL/keys
4. **Flutter Clean:** Run `flutter clean` and `flutter pub get`

## ✅ Success Indicators

After fixing the issue, you should be able to:

- ✅ Create new tasks successfully
- ✅ Mark tasks as complete/incomplete
- ✅ See streak counters update
- ✅ View tasks in the task list
- ✅ No foreign key constraint errors

The task management system should now work perfectly with proper database relationships and constraints!
