-- Create calendar_syncs table
CREATE TABLE calendar_syncs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID NOT NULL,
    provider VARCHAR(50) NOT NULL,
    calendar_id VARCHAR(255) NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    last_synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_profile
        FOREIGN KEY(profile_id)
        REFERENCES profiles(id)
        ON DELETE CASCADE
);

-- Create calendar_events table for caching external calendar events
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    calendar_sync_id UUID NOT NULL REFERENCES calendar_syncs(id) ON DELETE CASCADE,
    external_event_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(calendar_sync_id, external_event_id)
);

-- Create indexes
CREATE INDEX idx_calendar_syncs_profile_id ON calendar_syncs(profile_id);
CREATE INDEX idx_calendar_events_calendar_sync_id ON calendar_events(calendar_sync_id);
CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_calendar_syncs_updated_at
    BEFORE UPDATE ON calendar_syncs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE calendar_syncs ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for calendar_syncs
CREATE POLICY "Users can view their own calendar syncs"
    ON calendar_syncs FOR SELECT
    USING (profile_id = auth.uid());

CREATE POLICY "Users can manage their own calendar syncs"
    ON calendar_syncs FOR ALL
    USING (profile_id = auth.uid())
    WITH CHECK (profile_id = auth.uid());

-- Create RLS policies for calendar_events
CREATE POLICY "Users can view their own calendar events"
    ON calendar_events FOR SELECT
    USING (
        calendar_sync_id IN (
            SELECT id FROM calendar_syncs WHERE profile_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage their own calendar events"
    ON calendar_events FOR ALL
    USING (
        calendar_sync_id IN (
            SELECT id FROM calendar_syncs WHERE profile_id = auth.uid()
        )
    )
    WITH CHECK (
        calendar_sync_id IN (
            SELECT id FROM calendar_syncs WHERE profile_id = auth.uid()
        )
    ); 