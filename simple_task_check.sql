-- Simple Task Check - Run this to see what's happening with your tasks

-- 1. Show current user
SELECT auth.uid() as current_user_id;

-- 2. Show all tasks in the database
SELECT 
    id,
    user_id,
    name,
    created_at,
    CASE 
        WHEN user_id = auth.uid() THEN 'YOUR TASK'
        ELSE 'OTHER USER TASK'
    END as ownership
FROM tasks
ORDER BY created_at DESC;

-- 3. Show all task completions
SELECT 
    tc.id,
    tc.task_id,
    tc.completion_date,
    t.name as task_name,
    t.user_id as task_owner
FROM task_completions tc
LEFT JOIN tasks t ON t.id = tc.task_id
ORDER BY tc.created_at DESC;

-- 4. Check for orphaned completions
SELECT 
    'Orphaned completions (completions without matching tasks): ' || COUNT(*)::text as orphaned_count
FROM task_completions tc
WHERE NOT EXISTS (SELECT 1 FROM tasks t WHERE t.id = tc.task_id);

-- 5. Create a simple test task for debugging
INSERT INTO tasks (user_id, name, is_active, created_at, updated_at)
VALUES (
    auth.uid(),
    'DEBUG TEST TASK - ' || NOW()::text,
    true,
    NOW(),
    NOW()
)
RETURNING id, name;

-- 6. Show the test task that was just created
SELECT 
    'Test task created:' as info,
    id,
    name,
    user_id
FROM tasks 
WHERE user_id = auth.uid() 
AND name LIKE 'DEBUG TEST TASK%'
ORDER BY created_at DESC 
LIMIT 1;
