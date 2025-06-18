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
    ('work'),
    ('personal'),
    ('learning'),
    ('health'),
    ('finance')
ON CONFLICT (name) DO NOTHING;

-- 2. Schedule Types Table
CREATE TABLE IF NOT EXISTS schedule_types (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default schedule types
INSERT INTO schedule_types (name) VALUES 
    ('one-time'),
    ('daily'),
    ('weekly'),
    ('bi-weekly'),
    ('monthly'),
    ('bi-monthly')
ON CONFLICT (name) DO NOTHING;

-- 3. Drop existing tasks table if it exists (backup your data first!)
-- DROP TABLE IF EXISTS tasks CASCADE;

-- 4. Create new enhanced tasks table
CREATE TABLE IF NOT EXISTS enhanced_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    schedule_type_id UUID REFERENCES schedule_types(id) ON DELETE SET NULL,
    due_date DATE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Task Completions Table (for streak tracking)
CREATE TABLE IF NOT EXISTS task_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_id UUID REFERENCES enhanced_tasks(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(task_id, completion_date)
);

-- 6. Enable RLS for enhanced_tasks
ALTER TABLE enhanced_tasks ENABLE ROW LEVEL SECURITY;

-- Create policies for enhanced_tasks - users can only access their own tasks
CREATE POLICY "Users can view their own enhanced tasks" ON enhanced_tasks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own enhanced tasks" ON enhanced_tasks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own enhanced tasks" ON enhanced_tasks
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own enhanced tasks" ON enhanced_tasks
    FOR DELETE USING (auth.uid() = user_id);

-- 7. Enable RLS for task_completions
ALTER TABLE task_completions ENABLE ROW LEVEL SECURITY;

-- Create policies for task_completions - users can only access completions for their own tasks
CREATE POLICY "Users can view their own task completions" ON task_completions
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM enhanced_tasks 
            WHERE enhanced_tasks.id = task_completions.task_id 
            AND enhanced_tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert their own task completions" ON task_completions
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM enhanced_tasks 
            WHERE enhanced_tasks.id = task_completions.task_id 
            AND enhanced_tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own task completions" ON task_completions
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM enhanced_tasks 
            WHERE enhanced_tasks.id = task_completions.task_id 
            AND enhanced_tasks.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own task completions" ON task_completions
    FOR DELETE USING (
        EXISTS (
            SELECT 1 FROM enhanced_tasks 
            WHERE enhanced_tasks.id = task_completions.task_id 
            AND enhanced_tasks.user_id = auth.uid()
        )
    );

-- 8. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_user_id ON enhanced_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_due_date ON enhanced_tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_category_id ON enhanced_tasks(category_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_schedule_type_id ON enhanced_tasks(schedule_type_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_is_active ON enhanced_tasks(is_active);

CREATE INDEX IF NOT EXISTS idx_task_completions_task_id ON task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_completion_date ON task_completions(completion_date);

-- 9. Create trigger for updated_at on enhanced_tasks
CREATE TRIGGER update_enhanced_tasks_updated_at BEFORE UPDATE ON enhanced_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 10. Categories and schedule_types are public (no RLS needed as they're reference data)
-- But if you want to restrict access, you can enable RLS and create appropriate policies

-- Optional: Create a view for tasks with related data
CREATE OR REPLACE VIEW tasks_with_details AS
SELECT 
    t.*,
    c.name as category_name,
    st.name as schedule_type_name
FROM enhanced_tasks t
LEFT JOIN categories c ON t.category_id = c.id
LEFT JOIN schedule_types st ON t.schedule_type_id = st.id
WHERE t.is_active = true;

-- Grant access to the view
GRANT SELECT ON tasks_with_details TO authenticated;
