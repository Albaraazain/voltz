-- Create direct_requests table
CREATE TABLE IF NOT EXISTS direct_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    homeowner_id UUID NOT NULL REFERENCES homeowners(id) ON DELETE CASCADE,
    electrician_id UUID NOT NULL REFERENCES electricians(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    preferred_date DATE NOT NULL,
    preferred_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    decline_reason TEXT,
    alternative_date DATE,
    alternative_time TIME,
    alternative_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_status CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED'))
);

-- Create reschedule_requests table
CREATE TABLE IF NOT EXISTS reschedule_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    requested_by_id UUID NOT NULL,
    requested_by_type VARCHAR(20) NOT NULL,
    original_date DATE NOT NULL,
    original_time TIME NOT NULL,
    proposed_date DATE NOT NULL,
    proposed_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_status CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED')),
    CONSTRAINT valid_requested_by_type CHECK (requested_by_type IN ('HOMEOWNER', 'ELECTRICIAN'))
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_direct_requests_electrician_id ON direct_requests(electrician_id);
CREATE INDEX IF NOT EXISTS idx_direct_requests_homeowner_id ON direct_requests(homeowner_id);
CREATE INDEX IF NOT EXISTS idx_direct_requests_status ON direct_requests(status);
CREATE INDEX IF NOT EXISTS idx_direct_requests_preferred_date ON direct_requests(preferred_date);

CREATE INDEX IF NOT EXISTS idx_reschedule_requests_job_id ON reschedule_requests(job_id);
CREATE INDEX IF NOT EXISTS idx_reschedule_requests_requested_by_id ON reschedule_requests(requested_by_id);
CREATE INDEX IF NOT EXISTS idx_reschedule_requests_status ON reschedule_requests(status);
CREATE INDEX IF NOT EXISTS idx_reschedule_requests_original_date ON reschedule_requests(original_date);

-- Create triggers for updated_at columns
CREATE TRIGGER update_direct_requests_updated_at
    BEFORE UPDATE ON direct_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reschedule_requests_updated_at
    BEFORE UPDATE ON reschedule_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE direct_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE reschedule_requests ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for direct_requests
CREATE POLICY "Enable read access for involved parties" ON direct_requests
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = homeowner_id
            UNION
            SELECT profile_id FROM electricians WHERE id = electrician_id
        )
    );

CREATE POLICY "Enable insert for homeowners" ON direct_requests
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = homeowner_id
        )
    );

CREATE POLICY "Enable update for involved parties" ON direct_requests
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = homeowner_id
            UNION
            SELECT profile_id FROM electricians WHERE id = electrician_id
        )
    );

-- Create RLS policies for reschedule_requests
CREATE POLICY "Enable read access for job participants" ON reschedule_requests
    FOR SELECT
    USING (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = (
                SELECT homeowner_id FROM jobs WHERE id = job_id
            )
            UNION
            SELECT profile_id FROM electricians WHERE id = (
                SELECT electrician_id FROM jobs WHERE id = job_id
            )
        )
    );

CREATE POLICY "Enable insert for job participants" ON reschedule_requests
    FOR INSERT
    WITH CHECK (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = (
                SELECT homeowner_id FROM jobs WHERE id = job_id
            )
            UNION
            SELECT profile_id FROM electricians WHERE id = (
                SELECT electrician_id FROM jobs WHERE id = job_id
            )
        )
    );

CREATE POLICY "Enable update for job participants" ON reschedule_requests
    FOR UPDATE
    USING (
        auth.uid() IN (
            SELECT profile_id FROM homeowners WHERE id = (
                SELECT homeowner_id FROM jobs WHERE id = job_id
            )
            UNION
            SELECT profile_id FROM electricians WHERE id = (
                SELECT electrician_id FROM jobs WHERE id = job_id
            )
        )
    ); 