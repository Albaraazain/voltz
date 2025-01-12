-- Update electricians table
ALTER TABLE electricians
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS profile_image TEXT,
ADD COLUMN IF NOT EXISTS services JSONB DEFAULT '[]'::JSONB,
ADD COLUMN IF NOT EXISTS working_hours JSONB DEFAULT '{}'::JSONB,
ADD COLUMN IF NOT EXISTS payment_info JSONB,
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "new_job_requests": true,
  "job_updates": true,
  "messages": true,
  "weekly_summary": true,
  "payment_updates": true,
  "promotions": false,
  "quiet_hours_enabled": false,
  "quiet_hours_start_hour": 22,
  "quiet_hours_start_minute": 0,
  "quiet_hours_end_hour": 7,
  "quiet_hours_end_minute": 0
}'::JSONB;

-- Create storage bucket for profile images if it doesn't exist
INSERT INTO storage.buckets (id, name)
VALUES ('profile_images', 'profile_images')
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
CREATE POLICY "Allow users to upload their own profile images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile_images' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Allow public viewing of profile images"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile_images');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_electricians_rating ON electricians(rating);
CREATE INDEX IF NOT EXISTS idx_electricians_hourly_rate ON electricians(hourly_rate);
CREATE INDEX IF NOT EXISTS idx_electricians_is_available ON electricians(is_available);
CREATE INDEX IF NOT EXISTS idx_electricians_is_verified ON electricians(is_verified);

-- Update RLS policies
ALTER TABLE electricians ENABLE ROW LEVEL SECURITY;

-- Allow read access to verified electricians
CREATE POLICY "Read verified electricians"
ON electricians FOR SELECT
USING (is_verified = true OR auth.uid()::text = profile_id);

-- Allow electricians to update their own profiles
CREATE POLICY "Update own profile"
ON electricians FOR UPDATE
USING (auth.uid()::text = profile_id);

-- Allow electricians to update their own availability
CREATE POLICY "Update own availability"
ON electricians FOR UPDATE
USING (auth.uid()::text = profile_id)
WITH CHECK (
  -- Only allow updating specific columns
  (
    OLD.id = NEW.id AND
    OLD.profile_id = NEW.profile_id AND
    OLD.is_verified = NEW.is_verified
  )
); 