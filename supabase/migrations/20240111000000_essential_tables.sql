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
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Reviews policies
CREATE POLICY "Enable read access for all users" ON reviews FOR SELECT USING (true);

CREATE POLICY "Enable insert for job participants" ON reviews FOR INSERT 
  WITH CHECK ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid() 
    AND EXISTS (
      SELECT 1 FROM jobs 
      WHERE jobs.id = reviews.job_id 
      AND jobs.homeowner_id = reviews.homeowner_id
      AND jobs.electrician_id = reviews.electrician_id
    ));

CREATE POLICY "Enable update for review owner and electrician reply" ON reviews FOR UPDATE 
  USING (
    (SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid()
    OR 
    ((SELECT profile_id FROM electricians WHERE id = electrician_id) = auth.uid() 
     AND (OLD.electrician_reply IS NULL OR OLD.electrician_reply = NEW.electrician_reply)
     AND OLD.rating = NEW.rating 
     AND OLD.comment = NEW.comment)
  );

-- Notifications policies
CREATE POLICY "Enable read access for own notifications" ON notifications FOR SELECT 
  USING (profile_id = auth.uid());

CREATE POLICY "Enable insert for system" ON notifications FOR INSERT 
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Enable update for own notifications" ON notifications FOR UPDATE 
  USING (profile_id = auth.uid())
  WITH CHECK (
    OLD.profile_id = NEW.profile_id 
    AND OLD.title = NEW.title 
    AND OLD.message = NEW.message
    AND OLD.type = NEW.type
    AND OLD.related_id = NEW.related_id
  );

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
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_reviews_electrician_id ON reviews(electrician_id);
CREATE INDEX IF NOT EXISTS idx_reviews_job_id ON reviews(job_id);
CREATE INDEX IF NOT EXISTS idx_notifications_profile_id ON notifications(profile_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_payments_job_id ON payments(job_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status); 