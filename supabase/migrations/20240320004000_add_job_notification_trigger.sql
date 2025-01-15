-- Function to create job status notifications
CREATE OR REPLACE FUNCTION create_job_status_notification()
RETURNS TRIGGER AS $$
DECLARE
    homeowner_profile_id UUID;
    electrician_profile_id UUID;
    notification_title TEXT;
    notification_message TEXT;
    notification_type TEXT;
BEGIN
    -- Get profile IDs
    SELECT profile_id INTO homeowner_profile_id
    FROM homeowners
    WHERE id = NEW.homeowner_id;

    SELECT profile_id INTO electrician_profile_id
    FROM electricians
    WHERE id = NEW.electrician_id;

    -- Handle both INSERT and UPDATE operations
    IF TG_OP = 'INSERT' THEN
        -- For new jobs, always create a notification for the electrician
        IF electrician_profile_id IS NOT NULL THEN
            INSERT INTO notifications (
                profile_id,
                title,
                message,
                type,
                related_id
            ) VALUES (
                electrician_profile_id,
                'New Job Request',
                'You have a new job request: ' || NEW.title,
                'job_request',
                NEW.id
            );
        END IF;
    ELSIF TG_OP = 'UPDATE' AND OLD.status != NEW.status THEN
        -- Set notification content based on new status
        CASE NEW.status
            WHEN 'pending' THEN
                notification_title := 'New Job Request';
                notification_message := 'You have a new job request: ' || NEW.title;
                notification_type := 'job_request';
            WHEN 'accepted' THEN
                notification_title := 'Job Accepted';
                notification_message := 'Your job request has been accepted: ' || NEW.title;
                notification_type := 'job_update';
            WHEN 'declined' THEN
                notification_title := 'Job Declined';
                notification_message := 'Your job request has been declined: ' || NEW.title;
                notification_type := 'job_update';
            WHEN 'in_progress' THEN
                notification_title := 'Job Started';
                notification_message := 'Work has begun on your job: ' || NEW.title;
                notification_type := 'job_update';
            WHEN 'completed' THEN
                notification_title := 'Job Completed';
                notification_message := 'Your job has been marked as completed: ' || NEW.title;
                notification_type := 'job_update';
            WHEN 'cancelled' THEN
                notification_title := 'Job Cancelled';
                notification_message := 'The job has been cancelled: ' || NEW.title;
                notification_type := 'job_update';
        END CASE;

        -- Create notification for homeowner
        IF homeowner_profile_id IS NOT NULL THEN
            INSERT INTO notifications (
                profile_id,
                title,
                message,
                type,
                related_id
            ) VALUES (
                homeowner_profile_id,
                notification_title,
                notification_message,
                notification_type,
                NEW.id
            );
        END IF;

        -- Create notification for electrician if assigned
        IF electrician_profile_id IS NOT NULL AND NEW.status != 'pending' THEN
            INSERT INTO notifications (
                profile_id,
                title,
                message,
                type,
                related_id
            ) VALUES (
                electrician_profile_id,
                notification_title,
                notification_message,
                notification_type,
                NEW.id
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS job_status_notification_trigger ON jobs;
DROP TRIGGER IF EXISTS job_creation_notification_trigger ON jobs;

-- Create triggers for both INSERT and UPDATE
CREATE TRIGGER job_status_notification_trigger
    AFTER UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION create_job_status_notification();

CREATE TRIGGER job_creation_notification_trigger
    AFTER INSERT ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION create_job_status_notification();

-- Update RLS policies to allow the trigger to create notifications
DROP POLICY IF EXISTS "Enable insert for job notifications" ON notifications;
CREATE POLICY "Enable insert for job notifications" ON notifications
    FOR INSERT TO authenticated
    WITH CHECK (
        auth.uid() IN (
            -- Allow if user is the homeowner
            SELECT h.profile_id FROM homeowners h
            JOIN jobs j ON j.homeowner_id = h.id
            WHERE j.id = notifications.related_id
            UNION
            -- Allow if user is the electrician
            SELECT e.profile_id FROM electricians e
            JOIN jobs j ON j.electrician_id = e.id
            WHERE j.id = notifications.related_id
        )
    ); 