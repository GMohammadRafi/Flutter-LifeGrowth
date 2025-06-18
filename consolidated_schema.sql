-- Consolidated Life Growth App Database Schema for Supabase
-- This file combines all features and resolves policy naming conflicts
-- Run these commands in your Supabase SQL Editor

-- Enable Row Level Security (RLS) for all tables
-- This ensures users can only access their own data

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

-- 3. Enhanced Tasks Table (main tasks table)
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

-- 4. Task Completions Table (for streak tracking)
CREATE TABLE IF NOT EXISTS task_completions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    task_id UUID REFERENCES enhanced_tasks(id) ON DELETE CASCADE NOT NULL,
    completion_date DATE NOT NULL,
    is_completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(task_id, completion_date)
);

-- Enable RLS for enhanced_tasks
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

-- Enable RLS for task_completions
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

-- 5. Habits Table
CREATE TABLE IF NOT EXISTS habits (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    frequency TEXT DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'monthly')),
    category TEXT DEFAULT 'Health',
    is_active BOOLEAN DEFAULT TRUE,
    reminder_time TEXT, -- Format: HH:MM
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for habits
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

-- Create policies for habits
CREATE POLICY "Users can view their own habits" ON habits
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own habits" ON habits
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own habits" ON habits
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habits" ON habits
    FOR DELETE USING (auth.uid() = user_id);

-- 6. Habit Tracking Table
CREATE TABLE IF NOT EXISTS habit_tracking (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    habit_id UUID REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(habit_id, user_id, date)
);

-- Enable RLS for habit_tracking
ALTER TABLE habit_tracking ENABLE ROW LEVEL SECURITY;

-- Create policies for habit_tracking
CREATE POLICY "Users can view their own habit tracking" ON habit_tracking
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own habit tracking" ON habit_tracking
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own habit tracking" ON habit_tracking
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own habit tracking" ON habit_tracking
    FOR DELETE USING (auth.uid() = user_id);

-- 7. Health Data Table
CREATE TABLE IF NOT EXISTS health_data (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    date DATE NOT NULL,
    steps INTEGER,
    water_glasses INTEGER,
    sleep_hours DECIMAL(3,1),
    exercise_minutes INTEGER,
    weight DECIMAL(5,2),
    mood TEXT CHECK (mood IN ('excellent', 'good', 'okay', 'poor', 'terrible')),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- Enable RLS for health_data
ALTER TABLE health_data ENABLE ROW LEVEL SECURITY;

-- Create policies for health_data
CREATE POLICY "Users can view their own health data" ON health_data
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own health data" ON health_data
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own health data" ON health_data
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own health data" ON health_data
    FOR DELETE USING (auth.uid() = user_id);

-- 8. User Profiles Table (optional - for additional user data)
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    avatar_url TEXT,
    date_of_birth DATE,
    timezone TEXT DEFAULT 'UTC',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS for user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_profiles
CREATE POLICY "Users can view their own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_user_id ON enhanced_tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_due_date ON enhanced_tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_category_id ON enhanced_tasks(category_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_schedule_type_id ON enhanced_tasks(schedule_type_id);
CREATE INDEX IF NOT EXISTS idx_enhanced_tasks_is_active ON enhanced_tasks(is_active);

CREATE INDEX IF NOT EXISTS idx_task_completions_task_id ON task_completions(task_id);
CREATE INDEX IF NOT EXISTS idx_task_completions_completion_date ON task_completions(completion_date);

CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_is_active ON habits(is_active);

CREATE INDEX IF NOT EXISTS idx_habit_tracking_user_id ON habit_tracking(user_id);
CREATE INDEX IF NOT EXISTS idx_habit_tracking_date ON habit_tracking(date);
CREATE INDEX IF NOT EXISTS idx_habit_tracking_habit_id ON habit_tracking(habit_id);

CREATE INDEX IF NOT EXISTS idx_health_data_user_id ON health_data(user_id);
CREATE INDEX IF NOT EXISTS idx_health_data_date ON health_data(date);

-- Create functions for automatic updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_enhanced_tasks_updated_at BEFORE UPDATE ON enhanced_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON habits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_data_updated_at BEFORE UPDATE ON health_data
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically create user profile when user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

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