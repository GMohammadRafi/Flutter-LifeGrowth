-- Fix RLS Policies for Task Completions
-- Run this in your Supabase SQL Editor to fix the RLS policy error

-- 1. Drop existing policies for task_completions
DROP POLICY IF EXISTS "Users can view their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can insert their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can update their own task completions" ON task_completions;
DROP POLICY IF EXISTS "Users can delete their own task completions" ON task_completions;

-- 2. Create simpler, more reliable RLS policies for task_completions
CREATE POLICY "Enable read access for users on their task completions" ON task_completions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable insert access for users on their task completions" ON task_completions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable update access for users on their task completions" ON task_completions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Enable delete access for users on their task completions" ON task_completions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

-- 3. Alternative: If the above still doesn't work, temporarily disable RLS for debugging
-- Uncomment the line below ONLY for testing (remember to re-enable it later)
-- ALTER TABLE task_completions DISABLE ROW LEVEL SECURITY;

-- 4. Check if the tasks table has proper RLS policies
-- Ensure tasks table policies exist and are working
DO $$
BEGIN
    -- Check if tasks table has RLS enabled
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relname = 'tasks' 
        AND n.nspname = 'public'
        AND c.relrowsecurity = true
    ) THEN
        ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
    END IF;
END $$;

-- 5. Ensure tasks table has proper policies
DROP POLICY IF EXISTS "Users can view their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can insert their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can update their own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can delete their own tasks" ON tasks;

CREATE POLICY "Enable read access for users on their tasks" ON tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Enable insert access for users on their tasks" ON tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Enable update access for users on their tasks" ON tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Enable delete access for users on their tasks" ON tasks
    FOR DELETE USING (auth.uid() = user_id);

-- 6. Grant necessary permissions
GRANT ALL ON tasks TO authenticated;
GRANT ALL ON task_completions TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- 7. Test query to verify policies work
-- This should return tasks for the current user
-- SELECT * FROM tasks WHERE user_id = auth.uid() LIMIT 1;

-- 8. If you're still having issues, you can temporarily use a more permissive policy
-- Uncomment the lines below for debugging (NOT recommended for production)
/*
DROP POLICY IF EXISTS "Enable insert access for users on their task completions" ON task_completions;
CREATE POLICY "Temporary permissive insert policy" ON task_completions
    FOR INSERT WITH CHECK (true);
*/
