-- Drop existing scheduling-related tables if they exist
DROP TABLE IF EXISTS availability_slots CASCADE;
DROP TABLE IF EXISTS schedule_slots CASCADE;
DROP TABLE IF EXISTS electrician_availability CASCADE;
DROP TABLE IF EXISTS working_hours CASCADE;

-- Create unified schedule_slots table
CREATE TABLE schedule_slots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    electrician_id UUID NOT NULL REFERENCES electricians(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    job_id UUID REFERENCES jobs(id) ON DELETE SET NULL,
    recurring_rule TEXT, -- For recurring availability patterns
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_times CHECK (start_time < end_time),
    CONSTRAINT valid_status CHECK (status IN ('AVAILABLE', 'BOOKED', 'BLOCKED', 'PENDING', 'CANCELLED'))
);

-- Create working_hours table
CREATE TABLE working_hours (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    electrician_id UUID NOT NULL REFERENCES electricians(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_working_day BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_working_hours CHECK (start_time < end_time),
    UNIQUE(electrician_id, day_of_week)
);

-- Create indexes
CREATE INDEX idx_schedule_slots_electrician_id ON schedule_slots(electrician_id);
CREATE INDEX idx_schedule_slots_date ON schedule_slots(date);
CREATE INDEX idx_schedule_slots_status ON schedule_slots(status);
CREATE INDEX idx_schedule_slots_job_id ON schedule_slots(job_id);
CREATE INDEX idx_working_hours_electrician_id ON working_hours(electrician_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_schedule_slots_updated_at
    BEFORE UPDATE ON schedule_slots
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_working_hours_updated_at
    BEFORE UPDATE ON working_hours
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE schedule_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE working_hours ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for schedule_slots
CREATE POLICY "Users can view all schedule slots"
    ON schedule_slots FOR SELECT
    USING (true);

CREATE POLICY "Electricians can manage their own slots"
    ON schedule_slots FOR ALL
    USING (electrician_id = auth.uid())
    WITH CHECK (electrician_id = auth.uid());

-- Create RLS policies for working_hours
CREATE POLICY "Users can view all working hours"
    ON working_hours FOR SELECT
    USING (true);

CREATE POLICY "Electricians can manage their own working hours"
    ON working_hours FOR ALL
    USING (electrician_id = auth.uid())
    WITH CHECK (electrician_id = auth.uid());

-- Create helper functions
CREATE OR REPLACE FUNCTION check_slot_availability(
    p_electrician_id UUID,
    p_date DATE,
    p_start_time TIME,
    p_end_time TIME
) RETURNS BOOLEAN AS $$
DECLARE
    v_conflicts INTEGER;
BEGIN
    -- Check for overlapping slots
    SELECT COUNT(*)
    INTO v_conflicts
    FROM schedule_slots
    WHERE electrician_id = p_electrician_id
    AND date = p_date
    AND status NOT IN ('CANCELLED')
    AND (
        (start_time, end_time) OVERLAPS (p_start_time, p_end_time)
    );

    RETURN v_conflicts = 0;
END;
$$ LANGUAGE plpgsql;

-- Create function to create a booking
CREATE OR REPLACE FUNCTION create_booking(
    p_electrician_id UUID,
    p_homeowner_id UUID,
    p_date DATE,
    p_start_time TIME,
    p_end_time TIME,
    p_description TEXT
) RETURNS UUID AS $$
DECLARE
    v_job_id UUID;
    v_slot_id UUID;
BEGIN
    -- Check if slot is available
    IF NOT check_slot_availability(p_electrician_id, p_date, p_start_time, p_end_time) THEN
        RAISE EXCEPTION 'Time slot is not available';
    END IF;

    -- Create job
    INSERT INTO jobs (
        electrician_id,
        homeowner_id,
        status,
        description,
        title,
        price,
        date
    ) VALUES (
        p_electrician_id,
        p_homeowner_id,
        'SCHEDULED',
        p_description,
        'Electrical Service',
        0.00, -- Price will be set by electrician
        p_date::timestamp with time zone + p_start_time::time::interval
    ) RETURNING id INTO v_job_id;

    -- Create schedule slot
    INSERT INTO schedule_slots (
        electrician_id,
        date,
        start_time,
        end_time,
        status,
        job_id
    ) VALUES (
        p_electrician_id,
        p_date,
        p_start_time,
        p_end_time,
        'BOOKED',
        v_job_id
    ) RETURNING id INTO v_slot_id;

    RETURN v_job_id;
END;
$$ LANGUAGE plpgsql; 