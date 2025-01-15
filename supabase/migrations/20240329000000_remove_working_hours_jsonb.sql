-- First verify that all data has been migrated
DO $$
DECLARE
    unmigrated_count INTEGER;
BEGIN
    -- Count electricians with working_hours data but no corresponding entries in working_hours table
    SELECT COUNT(*)
    INTO unmigrated_count
    FROM electricians e
    WHERE e.working_hours IS NOT NULL
    AND NOT EXISTS (
        SELECT 1
        FROM working_hours wh
        WHERE wh.electrician_id = e.id
    );

    IF unmigrated_count > 0 THEN
        RAISE EXCEPTION 'Found % electricians with unmigrated working hours data', unmigrated_count;
    END IF;
END;
$$;

-- Remove the working_hours column
ALTER TABLE electricians DROP COLUMN working_hours; 