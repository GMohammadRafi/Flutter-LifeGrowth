-- Cleanup script to remove existing conflicting policies
-- Run this BEFORE running the consolidated_schema.sql

-- Drop existing policies for task_completions table
DROP POLICY IF EXISTS "Users can view their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can insert their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can update their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can delete their own task completions" ON task_completions;

-- Drop existing policies for tasks table (if it exists)
DROP POLICY IF EXISTS "Users can view their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can insert their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can update their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can delete their own tasks" ON tasks;

-- Drop existing policies for enhanced_tasks table (if it exists)
DROP POLICY IF EXISTS "Users can view their own enhanced tasks" ON enhanced_tasks;
DROP POLICY IF EXISTS "Users can insert their own enhanced tasks" ON enhanced_tasks;
DROP POLICY IF EXISTS "Users can update their own enhanced tasks" ON enhanced_tasks;
DROP POLICY IF EXISTS "Users can delete their own enhanced tasks" ON enhanced_tasks;

-- Drop existing policies for habits table (if it exists)
DROP POLICY IF EXISTS "Users can view their own habits" ON habits;
DROP POLICY IF EXISTS "Users can insert their own habits" ON habits;
DROP POLICY IF EXISTS "Users can update their own habits" ON habits;
DROP POLICY IF EXISTS "Users can delete their own habits" ON habits;

-- Drop existing policies for habit_tracking table (if it exists)
DROP POLICY IF EXISTS "Users can view their own habit tracking" ON habit_tracking;
DROP POLICY IF EXISTS "Users can insert their own habit tracking" ON habit_tracking;
DROP POLICY IF EXISTS "Users can update their own habit tracking" ON habit_tracking;
DROP POLICY IF EXISTS "Users can delete their own habit tracking" ON habit_tracking;

-- Drop existing policies for health_data table (if it exists)
DROP POLICY IF EXISTS "Users can view their own health data" ON health_data;
DROP POLICY IF EXISTS "Users can insert their own health data" ON health_data;
DROP POLICY IF EXISTS "Users can update their own health data" ON health_data;
DROP POLICY IF EXISTS "Users can delete their own health data" ON health_data;

-- Drop existing policies for user_profiles table (if it exists)
DROP POLICY IF EXISTS "Users can view their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;

-- Note: This script only drops policies, it doesn't drop tables or data
-- After running this, you can safely run the consolidated_schema.sql 