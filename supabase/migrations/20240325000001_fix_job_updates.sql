-- Drop existing policy and trigger for jobs only
DROP POLICY IF EXISTS "Enable update for job participants" ON jobs;
DROP TRIGGER IF EXISTS update_jobs_updated_at ON jobs;

-- Add updated_at column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                  WHERE table_name = 'jobs' AND column_name = 'updated_at') THEN
        ALTER TABLE jobs ADD COLUMN updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;
    END IF;
END $$;

-- Create the trigger for jobs table
CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create the update policy
CREATE POLICY "Enable update for job participants" ON jobs FOR UPDATE 
USING (
    auth.uid() IN (
        SELECT profile_id FROM homeowners WHERE id = homeowner_id
        UNION
        SELECT profile_id FROM electricians WHERE id = electrician_id
    )
)
WITH CHECK (true); 