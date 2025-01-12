-- Add is_verified column to electricians table
ALTER TABLE electricians ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON electricians;
DROP POLICY IF EXISTS "Enable read access for verified electricians" ON electricians;
DROP POLICY IF EXISTS "Enable admin verification" ON electricians;

-- Create policies for electrician visibility
CREATE POLICY "Enable read access for verified electricians" ON electricians
    FOR SELECT
    USING (
        -- Admins can see all electricians
        (auth.jwt() ->> 'role' = 'admin')
        OR
        -- Electricians can see their own profile
        (auth.uid() = profile_id)
        OR
        -- Homeowners can only see verified electricians
        (
            EXISTS (
                SELECT 1 FROM profiles 
                WHERE id = auth.uid() 
                AND user_type = 'homeowner'
            )
            AND is_verified = true
        )
        OR
        -- Allow read access for all verified electricians
        (is_verified = true)
    );

-- Create policy for admin to update verification status
CREATE POLICY "Enable admin verification" ON electricians
    FOR UPDATE
    USING (auth.jwt() ->> 'role' = 'admin'); 