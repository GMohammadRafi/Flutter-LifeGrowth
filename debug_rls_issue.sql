-- Debug RLS Issue Script
-- Run this in Supabase SQL Editor to diagnose and fix RLS problems

-- 1. Check current user authentication
SELECT 
    'Current User ID: ' || COALESCE(auth.uid()::text, 'NULL') as user_info;

-- 2. Check if tasks table exists and has data
SELECT 
    'Tasks table row count: ' || COUNT(*)::text as task_count
FROM tasks;

-- 3. Check if any tasks exist for the current user
SELECT 
    'User tasks count: ' || COUNT(*)::text as user_task_count
FROM tasks 
WHERE user_id = auth.uid();

-- 4. Check RLS status for both tables
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled,
    hasrls as has_rls_policies
FROM pg_tables 
WHERE tablename IN ('tasks', 'task_completions')
AND schemaname = 'public';

-- 5. List all policies for our tables
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('tasks', 'task_completions')
ORDER BY tablename, cmd;

-- 6. Test if we can select from tasks (should work)
SELECT 
    'Can select tasks: ' || 
    CASE 
        WHEN COUNT(*) >= 0 THEN 'YES'
        ELSE 'NO'
    END as can_select_tasks
FROM tasks 
WHERE user_id = auth.uid();

-- 7. Check if task_completions table structure is correct
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'task_completions'
ORDER BY ordinal_position;

-- 8. Check foreign key constraints
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'task_completions';

-- 9. TEMPORARY FIX: Disable RLS on task_completions for testing
-- Uncomment the next line if you want to test without RLS temporarily
-- ALTER TABLE task_completions DISABLE ROW LEVEL SECURITY;

-- 10. ALTERNATIVE: Create a more permissive policy for debugging
-- This allows any authenticated user to insert task completions
-- (NOT for production use)
DROP POLICY IF EXISTS "Debug insert policy" ON task_completions;
CREATE POLICY "Debug insert policy" ON task_completions
    FOR INSERT 
    TO authenticated
    WITH CHECK (true);

-- 11. Also create permissive policies for other operations
DROP POLICY IF EXISTS "Debug select policy" ON task_completions;
CREATE POLICY "Debug select policy" ON task_completions
    FOR SELECT 
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Debug update policy" ON task_completions;
CREATE POLICY "Debug update policy" ON task_completions
    FOR UPDATE 
    TO authenticated
    USING (true);

DROP POLICY IF EXISTS "Debug delete policy" ON task_completions;
CREATE POLICY "Debug delete policy" ON task_completions
    FOR DELETE 
    TO authenticated
    USING (true);

-- 12. Grant explicit permissions
GRANT ALL PRIVILEGES ON task_completions TO authenticated;
GRANT ALL PRIVILEGES ON tasks TO authenticated;

-- 13. Test insert (this should work now)
-- You can test this manually by trying to mark a task complete in the app

-- 14. After testing, you can restore proper RLS policies by running:
/*
-- Remove debug policies
DROP POLICY IF EXISTS "Debug insert policy" ON task_completions;
DROP POLICY IF EXISTS "Debug select policy" ON task_completions;
DROP POLICY IF EXISTS "Debug update policy" ON task_completions;
DROP POLICY IF EXISTS "Debug delete policy" ON task_completions;

-- Restore proper policies
CREATE POLICY "Users can view their own task completions" ON task_completions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own task completions" ON task_completions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own task completions" ON task_completions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own task completions" ON task_completions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM tasks 
            WHERE tasks.id = task_completions.task_id 
            AND tasks.user_id = auth.uid()
        )
    );
*/
