-- Create electricians table
CREATE TABLE IF NOT EXISTS electricians (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  rating REAL DEFAULT 0.0,
  jobs_completed INTEGER DEFAULT 0,
  hourly_rate REAL DEFAULT 0.0,
  profile_image TEXT,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP WITH TIME ZONE
);

-- Create homeowners table
CREATE TABLE IF NOT EXISTS homeowners (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP WITH TIME ZONE
);

-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  electrician_id TEXT REFERENCES electricians(id),
  homeowner_id TEXT NOT NULL REFERENCES homeowners(id),
  price REAL NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create RLS policies
ALTER TABLE electricians ENABLE ROW LEVEL SECURITY;
ALTER TABLE homeowners ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Electricians policies
CREATE POLICY "Enable read access for all users" ON electricians FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON electricians FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for own profile" ON electricians FOR UPDATE USING (auth.uid() = id);

-- Homeowners policies
CREATE POLICY "Enable read access for all users" ON homeowners FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON homeowners FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for own profile" ON homeowners FOR UPDATE USING (auth.uid() = id);

-- Jobs policies
CREATE POLICY "Enable read access for involved parties" ON jobs FOR SELECT 
  USING (auth.uid() = homeowner_id OR auth.uid() = electrician_id);
CREATE POLICY "Enable insert for homeowners" ON jobs FOR INSERT 
  WITH CHECK (auth.uid() = homeowner_id);
CREATE POLICY "Enable update for involved parties" ON jobs FOR UPDATE 
  USING (auth.uid() = homeowner_id OR auth.uid() = electrician_id); 