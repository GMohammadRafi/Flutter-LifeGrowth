-- Fix Database Migration Script
-- Run this in your Supabase SQL Editor to fix the foreign key constraint issue

-- 1. First, create the categories and schedule_types tables if they don't exist
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

-- 2. Drop the task_completions table if it exists (to recreate with correct foreign key)
DROP TABLE IF EXISTS task_completions CASCADE;

-- 3. Update the existing tasks table structure
-- Add new columns if they don't exist
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS schedule_type_id UUID REFERENCES schedule_types(id) ON DELETE SET NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- Rename title to name if title column exists
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tasks' AND column_name = 'title') THEN
        ALTER TABLE tasks RENAME COLUMN title TO name;
    END IF;
END $$;

-- Update due_date column type to DATE if it's not already
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'tasks' 
        AND column_name = 'due_date' 
        AND data_type != 'date'
    ) THEN
        ALTER TABLE tasks ALTER COLUMN due_date TYPE DATE USING due_date::date;
    END IF;
END $$;

-- Remove old columns that are no longer needed
ALTER TABLE tasks DROP COLUMN IF EXISTS description;
ALTER TABLE tasks DROP COLUMN IF EXISTS priority;
ALTER TABLE tasks DROP COLUMN IF EXISTS category;
ALTER TABLE tasks DROP COLUMN IF EXISTS is_completed;
ALTER TABLE tasks DROP COLUMN IF EXISTS completed_at;

-- 4. Recreate task_completions table with correct foreign key reference
CREATE TABLE task_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_id UUID REFERENCES tasks(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(task_id, completion_date)
);

-- 5. Enable RLS for task_completions
ALTER TABLE task_completions ENABLE ROW LEVEL SECURITY;

-- 6. Create policies for task_completions
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

-- 7. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_category_id ON tasks(category_id);
CREATE INDEX IF NOT EXISTS idx_tasks_schedule_type_id ON tasks(schedule_type_id);
CREATE INDEX IF NOT EXISTS idx_tasks_is_active ON tasks(is_active);
CREATE INDEX IF NOT EXISTS idx_task_completions_task_id ON task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_completion_date ON task_completions(completion_date);

-- 8. Create a view for tasks with related data
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

-- Migration complete!
-- Your tasks table now has the enhanced structure and task_completions table is properly linked
