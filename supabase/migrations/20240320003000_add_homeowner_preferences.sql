-- Add notification preferences to homeowners table
ALTER TABLE homeowners 
ADD COLUMN IF NOT EXISTS notification_job_updates BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS notification_messages BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS notification_payments BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS notification_promotions BOOLEAN DEFAULT false;

-- Add contact preference enum type
DO $$ BEGIN
    CREATE TYPE contact_method AS ENUM ('email', 'phone', 'sms');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Update preferred_contact_method to use enum
ALTER TABLE homeowners 
ALTER COLUMN preferred_contact_method DROP DEFAULT,
ALTER COLUMN preferred_contact_method TYPE contact_method 
USING CASE 
    WHEN preferred_contact_method IS NULL OR preferred_contact_method = '' THEN 'email'::contact_method
    WHEN preferred_contact_method = 'email' THEN 'email'::contact_method
    WHEN preferred_contact_method = 'phone' THEN 'phone'::contact_method
    WHEN preferred_contact_method = 'sms' THEN 'sms'::contact_method
    ELSE 'email'::contact_method 
END;

-- Set default value for preferred_contact_method
ALTER TABLE homeowners 
ALTER COLUMN preferred_contact_method SET DEFAULT 'email'::contact_method;

-- Update any NULL values to default
UPDATE homeowners 
SET notification_job_updates = true,
    notification_messages = true,
    notification_payments = true,
    notification_promotions = false,
    preferred_contact_method = 'email'::contact_method
WHERE notification_job_updates IS NULL 
   OR notification_messages IS NULL 
   OR notification_payments IS NULL 
   OR notification_promotions IS NULL 
   OR preferred_contact_method IS NULL; 