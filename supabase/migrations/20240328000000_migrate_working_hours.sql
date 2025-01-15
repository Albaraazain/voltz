-- Function to convert day name to day_of_week number
CREATE OR REPLACE FUNCTION get_day_of_week(day_name TEXT)
RETURNS INTEGER AS $$
BEGIN
    RETURN CASE LOWER(day_name)
        WHEN 'sunday' THEN 0
        WHEN 'monday' THEN 1
        WHEN 'tuesday' THEN 2
        WHEN 'wednesday' THEN 3
        WHEN 'thursday' THEN 4
        WHEN 'friday' THEN 5
        WHEN 'saturday' THEN 6
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to migrate existing working hours
CREATE OR REPLACE FUNCTION migrate_working_hours()
RETURNS void AS $$
DECLARE
    e RECORD;
    day TEXT;
    day_schedule JSONB;
BEGIN
    -- For each electrician
    FOR e IN SELECT id, working_hours FROM electricians WHERE working_hours IS NOT NULL LOOP
        -- For each day in working_hours
        FOR day, day_schedule IN SELECT * FROM jsonb_each(e.working_hours) LOOP
            -- Only insert if the day schedule is not null and has valid times
            IF day_schedule IS NOT NULL 
               AND (day_schedule->>'start') IS NOT NULL 
               AND (day_schedule->>'end') IS NOT NULL THEN
                INSERT INTO working_hours (
                    electrician_id,
                    day_of_week,
                    start_time,
                    end_time,
                    is_working_day
                ) VALUES (
                    e.id,
                    get_day_of_week(day),
                    COALESCE((day_schedule->>'start')::TIME, '09:00'::TIME),
                    COALESCE((day_schedule->>'end')::TIME, '17:00'::TIME),
                    true
                )
                ON CONFLICT (electrician_id, day_of_week) DO UPDATE
                SET
                    start_time = EXCLUDED.start_time,
                    end_time = EXCLUDED.end_time,
                    is_working_day = true,
                    updated_at = NOW();
            ELSE
                -- Insert a non-working day with default times
                INSERT INTO working_hours (
                    electrician_id,
                    day_of_week,
                    start_time,
                    end_time,
                    is_working_day
                ) VALUES (
                    e.id,
                    get_day_of_week(day),
                    '09:00'::TIME,
                    '17:00'::TIME,
                    false
                )
                ON CONFLICT (electrician_id, day_of_week) DO UPDATE
                SET
                    is_working_day = false,
                    updated_at = NOW();
            END IF;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Helper function to get working hours for an electrician
CREATE OR REPLACE FUNCTION get_working_hours(p_electrician_id UUID)
RETURNS TABLE (
    day_of_week INTEGER,
    day_name TEXT,
    start_time TIME,
    end_time TIME,
    is_working_day BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wh.day_of_week,
        CASE wh.day_of_week
            WHEN 0 THEN 'Sunday'
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
        END::TEXT as day_name,
        wh.start_time,
        wh.end_time,
        wh.is_working_day
    FROM working_hours wh
    WHERE wh.electrician_id = p_electrician_id
    ORDER BY wh.day_of_week;
END;
$$ LANGUAGE plpgsql STABLE;

-- Helper function to check if an electrician is working at a specific date and time
CREATE OR REPLACE FUNCTION is_working_time(
    p_electrician_id UUID,
    p_date DATE,
    p_time TIME DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_day_of_week INTEGER;
    v_working_hours RECORD;
BEGIN
    -- Get the day of week (0-6, Sunday-Saturday)
    v_day_of_week := EXTRACT(DOW FROM p_date)::INTEGER;
    
    -- Get working hours for this day
    SELECT * INTO v_working_hours
    FROM working_hours
    WHERE electrician_id = p_electrician_id
    AND day_of_week = v_day_of_week;
    
    -- If no working hours found or not a working day, return false
    IF v_working_hours IS NULL OR NOT v_working_hours.is_working_day THEN
        RETURN false;
    END IF;
    
    -- If no specific time provided, just return true as the day is a working day
    IF p_time IS NULL THEN
        RETURN true;
    END IF;
    
    -- Check if the time falls within working hours
    RETURN p_time >= v_working_hours.start_time 
        AND p_time <= v_working_hours.end_time;
END;
$$ LANGUAGE plpgsql STABLE;

-- Migrate existing data
SELECT migrate_working_hours();

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION get_working_hours TO authenticated;
GRANT EXECUTE ON FUNCTION is_working_time TO authenticated;

-- We'll keep the working_hours JSONB column for now to maintain backward compatibility
-- It will be removed in a future migration after the application is updated 