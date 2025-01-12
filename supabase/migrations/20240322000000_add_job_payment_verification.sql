-- Add payment and verification fields to jobs table
ALTER TABLE jobs
ADD COLUMN IF NOT EXISTS payment_status TEXT NOT NULL DEFAULT 'payment_pending',
ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'verification_pending',
ADD COLUMN IF NOT EXISTS payment_details JSONB,
ADD COLUMN IF NOT EXISTS verification_details JSONB;

-- Add check constraints for valid status values
ALTER TABLE jobs
ADD CONSTRAINT valid_payment_status CHECK (
  payment_status IN (
    'payment_pending',
    'payment_processing',
    'payment_completed',
    'payment_failed',
    'payment_refunded'
  )
),
ADD CONSTRAINT valid_verification_status CHECK (
  verification_status IN (
    'verification_pending',
    'verification_approved',
    'verification_rejected'
  )
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_jobs_payment_status ON jobs(payment_status);
CREATE INDEX IF NOT EXISTS idx_jobs_verification_status ON jobs(verification_status);

-- Update RLS policies to include payment and verification status
CREATE POLICY "Enable payment status update for involved parties" ON jobs
  FOR UPDATE TO authenticated
  USING (
    auth.uid() = homeowner_id OR 
    auth.uid() = electrician_id
  )
  WITH CHECK (
    (auth.uid() = homeowner_id AND payment_status IN ('payment_pending', 'payment_processing')) OR
    (auth.uid() = electrician_id AND payment_status IN ('payment_completed', 'payment_failed'))
  );

CREATE POLICY "Enable verification status update for electricians" ON jobs
  FOR UPDATE TO authenticated
  USING (auth.uid() = electrician_id)
  WITH CHECK (
    verification_status IN ('verification_pending', 'verification_approved', 'verification_rejected')
  ); 