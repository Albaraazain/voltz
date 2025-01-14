-- Drop existing reviews table and its dependencies
DROP TABLE IF EXISTS reviews CASCADE;

-- Create reviews table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID NOT NULL,
    reviewer_id UUID NOT NULL,
    reviewee_id UUID NOT NULL,
    reviewer_type VARCHAR(20) NOT NULL, -- HOMEOWNER, ELECTRICIAN
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_job
        FOREIGN KEY(job_id)
        REFERENCES jobs(id)
        ON DELETE CASCADE
);

-- Create review_responses table
CREATE TABLE review_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_review
        FOREIGN KEY(review_id)
        REFERENCES reviews(id)
        ON DELETE CASCADE
);

-- Create indexes
CREATE INDEX idx_reviews_job_id ON reviews(job_id);
CREATE INDEX idx_reviews_reviewer_id ON reviews(reviewer_id);
CREATE INDEX idx_reviews_reviewee_id ON reviews(reviewee_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_review_responses_review_id ON review_responses(review_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_review_responses_updated_at
    BEFORE UPDATE ON review_responses
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable RLS
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE review_responses ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for reviews
CREATE POLICY "Users can view all reviews"
    ON reviews FOR SELECT
    USING (true);

CREATE POLICY "Users can create reviews for their jobs"
    ON reviews FOR INSERT
    WITH CHECK (
        reviewer_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM jobs
            WHERE jobs.id = job_id
            AND (
                (reviewer_type = 'HOMEOWNER' AND jobs.homeowner_id = reviewer_id)
                OR
                (reviewer_type = 'ELECTRICIAN' AND jobs.electrician_id = reviewer_id)
            )
        )
    );

CREATE POLICY "Users can update their own reviews"
    ON reviews FOR UPDATE
    USING (reviewer_id = auth.uid());

CREATE POLICY "Users can delete their own reviews"
    ON reviews FOR DELETE
    USING (reviewer_id = auth.uid());

-- Create RLS policies for review responses
CREATE POLICY "Users can view all review responses"
    ON review_responses FOR SELECT
    USING (true);

CREATE POLICY "Users can create responses to reviews about them"
    ON review_responses FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM reviews
            WHERE reviews.id = review_id
            AND reviews.reviewee_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own responses"
    ON review_responses FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM reviews
            WHERE reviews.id = review_id
            AND reviews.reviewee_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own responses"
    ON review_responses FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM reviews
            WHERE reviews.id = review_id
            AND reviews.reviewee_id = auth.uid()
        )
    ); 