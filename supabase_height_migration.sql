-- Migration to add height fields to user_profiles table
-- Run this in your Supabase SQL editor

-- Add height columns to user_profiles table
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS height_cm DECIMAL(5,2), -- Height in centimeters (e.g., 175.50)
ADD COLUMN IF NOT EXISTS height_unit TEXT DEFAULT 'cm' CHECK (height_unit IN ('cm', 'ft', 'm'));

-- Add comment for documentation
COMMENT ON COLUMN user_profiles.height_cm IS 'User height stored in centimeters for consistency';
COMMENT ON COLUMN user_profiles.height_unit IS 'Preferred unit for displaying height (cm, ft, m)';
