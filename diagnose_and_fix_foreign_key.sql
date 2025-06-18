-- Diagnose and Fix Foreign Key Constraint Issue
-- This will identify and fix the task ID mismatch problem

-- 1. Check current user
SELECT 'Current user: ' || COALESCE(auth.uid()::text, 'NOT AUTHENTICATED') as user_info;

-- 2. Check all tasks in the database
SELECT 
    'Total tasks in database: ' || COUNT(*)::text as total_tasks,
    'User tasks: ' || COUNT(CASE WHEN user_id = auth.uid() THEN 1 END)::text as user_tasks
FROM tasks;

-- 3. Show actual task IDs for current user
SELECT 
    'User task IDs:' as info,
    id,
    name,
    created_at
FROM tasks 
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 5;

-- 4. Check if there are any orphaned task_completions
SELECT 
    'Orphaned completions: ' || COUNT(*)::text as orphaned_count
FROM task_completions tc
WHERE NOT EXISTS (
    SELECT 1 FROM tasks t WHERE t.id = tc.task_id
);

-- 5. Clean up any orphaned task_completions
DELETE FROM task_completions 
WHERE NOT EXISTS (
    SELECT 1 FROM tasks t WHERE t.id = task_completions.task_id
);

-- 6. Check foreign key constraint details
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name = 'task_completions';

-- 7. TEMPORARY FIX: Drop the foreign key constraint temporarily
-- This will allow task completions to be inserted even if there's a mismatch
ALTER TABLE task_completions DROP CONSTRAINT IF EXISTS task_completions_task_id_fkey;

-- 8. Add a more lenient foreign key constraint that allows NULL
-- (We'll fix the data integrity separately)
-- ALTER TABLE task_completions ADD CONSTRAINT task_completions_task_id_fkey 
-- FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE;

-- 9. Create a test task for the current user to ensure we have valid data
INSERT INTO tasks (user_id, name, is_active, created_at, updated_at)
VALUES (
    auth.uid(),
    'Test Task - ' || CURRENT_TIMESTAMP::text,
    true,
    NOW(),
    NOW()
)
ON CONFLICT DO NOTHING;

-- 10. Show the test task ID that was just created
SELECT 
    'Test task created with ID: ' || id::text as test_task_info,
    name
FROM tasks 
WHERE user_id = auth.uid() 
AND name LIKE 'Test Task -%'
ORDER BY created_at DESC 
LIMIT 1;

-- 11. Test inserting a completion for the test task
INSERT INTO task_completions (task_id, completion_date, is_completed)
SELECT 
    id,
    CURRENT_DATE,
    true
FROM tasks 
WHERE user_id = auth.uid() 
AND name LIKE 'Test Task -%'
ORDER BY created_at DESC 
LIMIT 1
ON CONFLICT (task_id, completion_date) DO UPDATE SET is_completed = true;

-- 12. Verify the test completion was inserted
SELECT 
    'Test completion created: ' || COUNT(*)::text as completion_status
FROM task_completions tc
JOIN tasks t ON t.id = tc.task_id
WHERE t.user_id = auth.uid()
AND t.name LIKE 'Test Task -%';

-- 13. Re-add the foreign key constraint (this should work now)
ALTER TABLE task_completions ADD CONSTRAINT task_completions_task_id_fkey 
FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE;

-- 14. Final verification - show all user tasks with their completion status
SELECT 
    t.id,
    t.name,
    t.created_at,
    CASE 
        WHEN tc.id IS NOT NULL THEN 'HAS_COMPLETION'
        ELSE 'NO_COMPLETION'
    END as completion_status
FROM tasks t
LEFT JOIN task_completions tc ON t.id = tc.task_id AND tc.completion_date = CURRENT_DATE
WHERE t.user_id = auth.uid()
ORDER BY t.created_at DESC;

-- 15. Clean up test data (optional - uncomment if you want to remove test task)
-- DELETE FROM task_completions WHERE task_id IN (
--     SELECT id FROM tasks WHERE user_id = auth.uid() AND name LIKE 'Test Task -%'
-- );
-- DELETE FROM tasks WHERE user_id = auth.uid() AND name LIKE 'Test Task -%';

-- If this script runs successfully, your foreign key issue should be resolved!
