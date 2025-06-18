-- Test Database Access Script
-- Run this after the emergency fix to verify everything works

-- 1. Check current user
SELECT 'Current user ID: ' || COALESCE(auth.uid()::text, 'NOT AUTHENTICATED') as user_status;

-- 2. Check if we can read from categories
SELECT 'Categories count: ' || COUNT(*)::text as categories_status FROM categories;

-- 3. Check if we can read from schedule_types
SELECT 'Schedule types count: ' || COUNT(*)::text as schedule_types_status FROM schedule_types;

-- 4. Check if we can read from tasks
SELECT 'Total tasks count: ' || COUNT(*)::text as total_tasks FROM tasks;

-- 5. Check if we can read user's tasks
SELECT 'User tasks count: ' || COUNT(*)::text as user_tasks 
FROM tasks 
WHERE user_id = auth.uid();

-- 6. Check if we can read from task_completions
SELECT 'Task completions count: ' || COUNT(*)::text as completions_count 
FROM task_completions;

-- 7. Check RLS status
SELECT 
    tablename,
    CASE WHEN rowsecurity THEN 'ENABLED' ELSE 'DISABLED' END as rls_status
FROM pg_tables 
WHERE tablename IN ('tasks', 'task_completions', 'categories', 'schedule_types')
AND schemaname = 'public'
ORDER BY tablename;

-- 8. List current policies
SELECT 
    tablename,
    policyname,
    cmd as operation
FROM pg_policies 
WHERE tablename IN ('tasks', 'task_completions')
ORDER BY tablename, cmd;

-- 9. Test insert into task_completions (if you have a task)
-- Replace 'YOUR_TASK_ID' with an actual task ID from your tasks table
-- INSERT INTO task_completions (task_id, completion_date, is_completed) 
-- VALUES ('YOUR_TASK_ID', CURRENT_DATE, true);

-- 10. Show sample data structure
SELECT 
    'Sample task structure:' as info,
    id,
    name,
    category_id,
    schedule_type_id,
    user_id
FROM tasks 
WHERE user_id = auth.uid()
LIMIT 1;

-- If all these queries return results without errors, your database is working correctly!
