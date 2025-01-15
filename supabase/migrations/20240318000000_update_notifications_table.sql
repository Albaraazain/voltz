-- First remove all dependencies
DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
DROP POLICY IF EXISTS "Enable read access for own notifications" ON notifications;
DROP POLICY IF EXISTS "Enable insert for system" ON notifications;
DROP POLICY IF EXISTS "Enable update own notifications" ON notifications;
DROP POLICY IF EXISTS "Electricians can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "Electricians can update their own notifications" ON notifications;
DROP POLICY IF EXISTS "System can create notifications" ON notifications;

-- Remove existing indexes
DROP INDEX IF EXISTS idx_notifications_profile_id;
DROP INDEX IF EXISTS idx_notifications_is_read;
DROP INDEX IF EXISTS idx_notifications_electrician_id;
DROP INDEX IF EXISTS idx_notifications_read_status;
DROP INDEX IF EXISTS idx_notifications_created_at;

-- Alter existing table if it exists, create if it doesn't
DO $$ BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'notifications') THEN
        -- Remove existing constraints
        ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_electrician_id_fkey;
        ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_profile_id_fkey;
        ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_pkey;
        
        -- Drop existing columns that we don't want
        ALTER TABLE notifications 
            DROP COLUMN IF EXISTS electrician_id,
            DROP COLUMN IF EXISTS is_read;

        -- Add or modify columns to match new schema
        ALTER TABLE notifications
            ADD COLUMN IF NOT EXISTS profile_id UUID,
            ADD COLUMN IF NOT EXISTS title TEXT,
            ADD COLUMN IF NOT EXISTS message TEXT,
            ADD COLUMN IF NOT EXISTS type TEXT,
            ADD COLUMN IF NOT EXISTS read BOOLEAN DEFAULT false,
            ADD COLUMN IF NOT EXISTS related_id UUID,
            ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
            ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now());

        -- Update columns that exist to NOT NULL where needed
        ALTER TABLE notifications 
            ALTER COLUMN profile_id SET NOT NULL,
            ALTER COLUMN title SET NOT NULL,
            ALTER COLUMN message SET NOT NULL,
            ALTER COLUMN type SET NOT NULL,
            ALTER COLUMN read SET NOT NULL,
            ALTER COLUMN created_at SET NOT NULL,
            ALTER COLUMN updated_at SET NOT NULL;

        -- Add new constraints
        ALTER TABLE notifications 
            ADD CONSTRAINT notifications_pkey PRIMARY KEY (id),
            ADD CONSTRAINT notifications_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
            ADD CONSTRAINT notifications_type_check CHECK (type IN ('job_request', 'job_update', 'payment', 'review', 'system'));

    ELSE
        -- Create new notifications table if it doesn't exist
        CREATE TABLE notifications (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('job_request', 'job_update', 'payment', 'review', 'system')),
            read BOOLEAN NOT NULL DEFAULT false,
            related_id UUID,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
        );
    END IF;
END $$;

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_profile_id ON notifications(profile_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_status ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() = profile_id);

CREATE POLICY "Users can update their own notifications"
    ON notifications FOR UPDATE
    USING (auth.uid() = profile_id)
    WITH CHECK (auth.uid() = profile_id);

CREATE POLICY "System can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (true);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_notifications_updated_at
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column(); 