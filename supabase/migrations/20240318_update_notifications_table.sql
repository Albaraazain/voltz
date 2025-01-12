-- Drop old notifications table and its dependencies
DROP TRIGGER IF EXISTS update_notifications_updated_at ON notifications;
DROP POLICY IF EXISTS "Enable read access for own notifications" ON notifications;
DROP POLICY IF EXISTS "Enable insert for system" ON notifications;
DROP POLICY IF EXISTS "Enable update own notifications" ON notifications;
DROP INDEX IF EXISTS idx_notifications_profile_id;
DROP INDEX IF EXISTS idx_notifications_is_read;
DROP TABLE IF EXISTS notifications;

-- Create new notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    electrician_id UUID NOT NULL REFERENCES electricians(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('job_request', 'job_update', 'payment', 'review', 'system')),
    read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_electrician_id ON notifications(electrician_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read_status ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Enable Row Level Security
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Electricians can view their own notifications"
    ON notifications FOR SELECT
    USING (auth.uid() IN (
        SELECT profile_id 
        FROM electricians 
        WHERE id = electrician_id
    ));

CREATE POLICY "Electricians can update their own notifications"
    ON notifications FOR UPDATE
    USING (auth.uid() IN (
        SELECT profile_id 
        FROM electricians 
        WHERE id = electrician_id
    ))
    WITH CHECK (auth.uid() IN (
        SELECT profile_id 
        FROM electricians 
        WHERE id = electrician_id
    ));

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