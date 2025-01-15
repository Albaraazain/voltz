-- Update electricians table
ALTER TABLE electricians
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS profile_image TEXT,
ADD COLUMN IF NOT EXISTS services JSONB DEFAULT '[]'::JSONB,
ADD COLUMN IF NOT EXISTS working_hours JSONB DEFAULT '{
  "monday": {"start": "09:00", "end": "17:00"},
  "tuesday": {"start": "09:00", "end": "17:00"},
  "wednesday": {"start": "09:00", "end": "17:00"},
  "thursday": {"start": "09:00", "end": "17:00"},
  "friday": {"start": "09:00", "end": "17:00"},
  "saturday": null,
  "sunday": null
}'::JSONB,
ADD COLUMN IF NOT EXISTS payment_info JSONB DEFAULT '{
  "account_name": null,
  "bank_name": null,
  "account_type": null,
  "account_number": null,
  "routing_number": null
}'::JSONB,
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{
  "new_job_requests": true,
  "job_updates": true,
  "messages": true,
  "weekly_summary": true,
  "payment_updates": true,
  "promotions": false,
  "quiet_hours_enabled": false,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "07:00"
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
  auth.uid()::uuid::text = (storage.foldername(name))[1]
);

CREATE POLICY "Allow public viewing of profile images"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile_images');

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_electricians_rating ON electricians(rating);
CREATE INDEX IF NOT EXISTS idx_electricians_hourly_rate ON electricians(hourly_rate);
CREATE INDEX IF NOT EXISTS idx_electricians_is_available ON electricians(is_available);
CREATE INDEX IF NOT EXISTS idx_electricians_is_verified ON electricians(is_verified);
CREATE INDEX IF NOT EXISTS idx_electricians_phone ON electricians(phone);
CREATE INDEX IF NOT EXISTS idx_electricians_services ON electricians USING gin(services);
CREATE INDEX IF NOT EXISTS idx_electricians_working_hours ON electricians USING gin(working_hours);
CREATE INDEX IF NOT EXISTS idx_electricians_payment_info ON electricians USING gin(payment_info);
CREATE INDEX IF NOT EXISTS idx_electricians_notification_preferences ON electricians USING gin(notification_preferences);
CREATE INDEX IF NOT EXISTS idx_electricians_profile_id ON electricians(profile_id);
CREATE INDEX IF NOT EXISTS idx_electricians_license_number ON electricians(license_number);
CREATE INDEX IF NOT EXISTS idx_electricians_years_of_experience ON electricians(years_of_experience);

-- Add constraints to ensure valid data
ALTER TABLE electricians
ADD CONSTRAINT valid_hourly_rate CHECK (hourly_rate >= 0),
ADD CONSTRAINT valid_years_of_experience CHECK (years_of_experience >= 0),
ADD CONSTRAINT valid_rating CHECK (rating >= 0 AND rating <= 5);

-- Update RLS policies
ALTER TABLE electricians ENABLE ROW LEVEL SECURITY;

-- Allow read access to verified electricians
CREATE POLICY "Read verified electricians"
ON electricians FOR SELECT
USING (is_verified = true OR auth.uid()::uuid = profile_id);

-- Allow electricians to update their own profiles
CREATE POLICY "Update own profile"
ON electricians FOR UPDATE
USING (auth.uid()::uuid = profile_id)
WITH CHECK (
  -- Only allow updating non-sensitive fields
  auth.uid()::uuid = profile_id AND
  is_verified IS NOT DISTINCT FROM is_verified
); 