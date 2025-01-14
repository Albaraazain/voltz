-- Create calendar_syncs table
CREATE TABLE calendar_syncs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    provider VARCHAR(50) NOT NULL,
    calendar_id VARCHAR(255) NOT NULL,
    access_token TEXT NOT NULL,
    refresh_token TEXT,
    last_synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_user
        FOREIGN KEY(user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- Create calendar_events table for caching external calendar events
CREATE TABLE calendar_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    calendar_sync_id UUID NOT NULL,
    external_event_id VARCHAR(255) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_calendar_sync
        FOREIGN KEY(calendar_sync_id)
        REFERENCES calendar_syncs(id)
        ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_calendar_syncs_user_id ON calendar_syncs(user_id);
CREATE INDEX idx_calendar_events_calendar_sync_id ON calendar_events(calendar_sync_id);
CREATE INDEX idx_calendar_events_start_time ON calendar_events(start_time);
CREATE UNIQUE INDEX idx_calendar_events_external_id ON calendar_events(calendar_sync_id, external_event_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_calendar_syncs_updated_at
    BEFORE UPDATE ON calendar_syncs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_calendar_events_updated_at
    BEFORE UPDATE ON calendar_events
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create RLS policies
ALTER TABLE calendar_syncs ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_events ENABLE ROW LEVEL SECURITY;

-- Users can only view and manage their own calendar syncs
CREATE POLICY "Users can view their own calendar syncs"
    ON calendar_syncs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own calendar syncs"
    ON calendar_syncs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own calendar syncs"
    ON calendar_syncs FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own calendar syncs"
    ON calendar_syncs FOR DELETE
    USING (auth.uid() = user_id);

-- Users can only view calendar events from their synced calendars
CREATE POLICY "Users can view their calendar events"
    ON calendar_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM calendar_syncs
            WHERE calendar_syncs.id = calendar_events.calendar_sync_id
            AND calendar_syncs.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can manage their calendar events"
    ON calendar_events FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM calendar_syncs
            WHERE calendar_syncs.id = calendar_events.calendar_sync_id
            AND calendar_syncs.user_id = auth.uid()
        )
    ); 