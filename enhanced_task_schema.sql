-- Enhanced Task Management System Schema
-- Run these commands in your Supabase SQL Editor to add the new task management features

-- 1. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name) VALUES 
    ('Work'),
    ('Personal'),
    ('Learning'),
    ('Health'),
    ('Finance')
ON CONFLICT (name) DO NOTHING;

-- 2. Schedule Types Table
CREATE TABLE IF NOT EXISTS schedule_types (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default schedule types
INSERT INTO schedule_types (name) VALUES 
    ('One-Time'),
    ('Daily'),
    ('Weekly'),
    ('Bi-Weekly'),
    ('Monthly'),
    ('Bi-Monthly')
ON CONFLICT (name) DO NOTHING;

-- 3. Update existing tasks table to match new schema
-- First, let's add the new columns to the existing tasks table
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS schedule_type_id UUID REFERENCES schedule_types(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Rename title to name if it exists
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tasks' AND column_name = 'title') THEN
        ALTER TABLE tasks RENAME COLUMN title TO name;
    END IF;
END $$;

-- Update due_date column type if needed
ALTER TABLE tasks ALTER COLUMN due_date TYPE DATE;

-- Remove old columns that are no longer needed
ALTER TABLE tasks DROP COLUMN IF EXISTS description;
ALTER TABLE tasks DROP COLUMN IF EXISTS priority;
ALTER TABLE tasks DROP COLUMN IF EXISTS category;
ALTER TABLE tasks DROP COLUMN IF EXISTS is_completed;
ALTER TABLE tasks DROP COLUMN IF EXISTS completed_at;

-- 4. Task Completions Table (for streak tracking)
CREATE TABLE IF NOT EXISTS task_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(task_id, completion_date)
);

-- 5. RLS policies for tasks table should already exist, but let's ensure they're correct
-- The tasks table should already have RLS enabled from the original schema

-- 6. Enable RLS for task_completions
ALTER TABLE task_completions ENABLE ROW LEVEL SECURITY;

-- Create policies for task_completions - users can only access completions for their own tasks
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

-- 7. Create indexes for better performance (some may already exist)
CREATE INDEX IF NOT EXISTS idx_tasks_category_id ON tasks(category_id);
CREATE INDEX IF NOT EXISTS idx_tasks_schedule_type_id ON tasks(schedule_type_id);
CREATE INDEX IF NOT EXISTS idx_tasks_is_active ON tasks(is_active);

CREATE INDEX IF NOT EXISTS idx_task_completions_task_id ON task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_completion_date ON task_completions(completion_date);

-- 8. The trigger for tasks table should already exist from the original schema

-- 10. Categories and schedule_types are public (no RLS needed as they're reference data)
-- But if you want to restrict access, you can enable RLS and create appropriate policies

-- 9. Optional: Create a view for tasks with related data
CREATE OR REPLACE VIEW tasks_with_details AS
SELECT
    t.*,
    c.name as category_name,
    st.name as schedule_type_name
FROM tasks t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN schedule_types st ON t.schedule_type_id = st.id
WHERE t.is_active = true;

-- Grant access to the view
GRANT SELECT ON tasks_with_details TO authenticated;
