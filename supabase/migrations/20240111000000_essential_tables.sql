-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  homeowner_id UUID NOT NULL REFERENCES homeowners(id),
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  electrician_id UUID NOT NULL REFERENCES electricians(id),
  homeowner_id UUID NOT NULL REFERENCES homeowners(id),
  job_id UUID NOT NULL REFERENCES jobs(id),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  photos TEXT[],
  electrician_reply TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES jobs(id),
  amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL,
  payment_method TEXT NOT NULL,
  transaction_id TEXT,
  payer_id UUID NOT NULL REFERENCES profiles(id),
  payee_id UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON jobs;
DROP POLICY IF EXISTS "Enable insert for homeowners" ON jobs;
DROP POLICY IF EXISTS "Enable update for job participants" ON jobs;

DROP POLICY IF EXISTS "Enable read access for all users" ON reviews;
DROP POLICY IF EXISTS "Enable insert for job participants" ON reviews;
DROP POLICY IF EXISTS "Enable homeowner update" ON reviews;
DROP POLICY IF EXISTS "Enable electrician reply" ON reviews;

DROP POLICY IF EXISTS "Enable read access for own notifications" ON notifications;
DROP POLICY IF EXISTS "Enable insert for system" ON notifications;
DROP POLICY IF EXISTS "Enable update own notifications" ON notifications;

DROP POLICY IF EXISTS "Enable read access for payment participants" ON payments;
DROP POLICY IF EXISTS "Enable insert for system" ON payments;
DROP POLICY IF EXISTS "Enable update for system" ON payments;

-- Jobs policies
CREATE POLICY "Enable read access for all users" ON jobs FOR SELECT USING (true);

CREATE POLICY "Enable insert for homeowners" ON jobs FOR INSERT 
  WITH CHECK ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid());

CREATE POLICY "Enable update for job participants" ON jobs FOR UPDATE 
  USING ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid());

-- Reviews policies
CREATE POLICY "Enable read access for all users" ON reviews FOR SELECT USING (true);

CREATE POLICY "Enable insert for job participants" ON reviews FOR INSERT 
  WITH CHECK ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid() 
    AND EXISTS (
      SELECT 1 FROM jobs 
      WHERE jobs.id = reviews.job_id 
      AND jobs.homeowner_id = reviews.homeowner_id
    ));

CREATE POLICY "Enable homeowner update" ON reviews FOR UPDATE 
  USING ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid());

CREATE POLICY "Enable electrician reply" ON reviews FOR UPDATE 
  USING ((SELECT profile_id FROM electricians WHERE id = electrician_id) = auth.uid());

-- Notifications policies
CREATE POLICY "Enable read access for own notifications" ON notifications FOR SELECT 
  USING (profile_id = auth.uid());

CREATE POLICY "Enable insert for system" ON notifications FOR INSERT 
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Enable update own notifications" ON notifications FOR UPDATE 
  USING (profile_id = auth.uid())
  WITH CHECK (profile_id = auth.uid() AND is_read = true);

-- Payments policies
CREATE POLICY "Enable read access for payment participants" ON payments FOR SELECT 
  USING (payer_id = auth.uid() OR payee_id = auth.uid());

CREATE POLICY "Enable insert for system" ON payments FOR INSERT 
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Enable update for system" ON payments FOR UPDATE 
  USING (auth.role() = 'service_role');

-- Create functions for automatic timestamp updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at columns
DROP TRIGGER IF EXISTS update_jobs_updated_at ON jobs;
DROP TRIGGER IF EXISTS update_reviews_updated_at ON reviews;
DROP TRIGGER IF EXISTS update_payments_updated_at ON payments;

CREATE TRIGGER update_jobs_updated_at
    BEFORE UPDATE ON jobs
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create functions for handling review updates
CREATE OR REPLACE FUNCTION check_review_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Only allow electrician to update their reply
    IF auth.uid() = (SELECT profile_id FROM electricians WHERE id = NEW.electrician_id) THEN
        IF OLD.rating != NEW.rating OR 
           OLD.comment != NEW.comment OR 
           OLD.photos != NEW.photos OR 
           OLD.homeowner_id != NEW.homeowner_id OR 
           OLD.electrician_id != NEW.electrician_id OR 
           OLD.job_id != NEW.job_id THEN
            RAISE EXCEPTION 'Electrician can only update their reply';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql' SECURITY DEFINER;

-- Create trigger for review updates
DROP TRIGGER IF EXISTS check_review_update_trigger ON reviews;

CREATE TRIGGER check_review_update_trigger
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION check_review_update();

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_jobs_homeowner_id ON jobs(homeowner_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_reviews_electrician_id ON reviews(electrician_id);
CREATE INDEX IF NOT EXISTS idx_reviews_job_id ON reviews(job_id);
CREATE INDEX IF NOT EXISTS idx_notifications_profile_id ON notifications(profile_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_payments_job_id ON payments(job_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status); 