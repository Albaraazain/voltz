-- Drop existing tables if they exist (in correct order due to dependencies)
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS electricians;
DROP TABLE IF EXISTS homeowners;
DROP TABLE IF EXISTS profiles;

-- Drop existing trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Drop existing function
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create profiles table for auth
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL UNIQUE,
  user_type TEXT NOT NULL DEFAULT 'homeowner',
  name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP WITH TIME ZONE
);

-- Create trigger function for new user profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  user_type text;
  profile_id uuid;
BEGIN
  -- Safely handle the boolean conversion
  IF NEW.raw_user_meta_data->>'is_electrician' = 'true' THEN
    user_type := 'electrician';
  ELSE
    user_type := 'homeowner';
  END IF;

  -- Insert into profiles
  INSERT INTO profiles (id, email, user_type, name)
  VALUES (
    NEW.id,
    NEW.email,
    user_type,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Unknown')
  );

  -- Store the profile id for convenience
  profile_id := NEW.id;

  -- Create corresponding record based on user type
  IF user_type = 'homeowner' THEN
    INSERT INTO homeowners (profile_id)
    VALUES (profile_id);
  ELSE
    INSERT INTO electricians (profile_id)
    VALUES (profile_id);
  END IF;

  RETURN NEW;
END;
$$;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create electricians table
CREATE TABLE IF NOT EXISTS electricians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id),
  rating REAL DEFAULT 0.0,
  jobs_completed INTEGER DEFAULT 0,
  hourly_rate REAL DEFAULT 0.0,
  profile_image TEXT,
  is_available BOOLEAN DEFAULT true,
  specialties TEXT[],
  license_number TEXT,
  years_of_experience INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create homeowners table
CREATE TABLE IF NOT EXISTS homeowners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID REFERENCES profiles(id),
  phone TEXT,
  address TEXT,
  preferred_contact_method TEXT DEFAULT 'email',
  emergency_contact TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create jobs table
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  electrician_id UUID REFERENCES electricians(id),
  homeowner_id UUID NOT NULL REFERENCES homeowners(id),
  price REAL NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE electricians ENABLE ROW LEVEL SECURITY;
ALTER TABLE homeowners ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON electricians;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON electricians;
DROP POLICY IF EXISTS "Enable update for own profile" ON electricians;

DROP POLICY IF EXISTS "Enable read access for all users" ON homeowners;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON homeowners;
DROP POLICY IF EXISTS "Enable update for own profile" ON homeowners;

DROP POLICY IF EXISTS "Enable read access for involved parties" ON jobs;
DROP POLICY IF EXISTS "Enable insert for homeowners" ON jobs;
DROP POLICY IF EXISTS "Enable update for involved parties" ON jobs;

-- Profiles policies
CREATE POLICY "Enable read access for own profile" ON profiles FOR SELECT 
  USING (auth.uid() = id);
CREATE POLICY "Enable update for own profile" ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- Electricians policies
CREATE POLICY "Enable read access for all users" ON electricians FOR SELECT USING (true);
CREATE POLICY "Enable insert for electrician profiles" ON electricians FOR INSERT 
  WITH CHECK ((SELECT user_type FROM profiles WHERE id = profile_id) = 'electrician');
CREATE POLICY "Enable update for own profile" ON electricians FOR UPDATE 
  USING ((SELECT id FROM profiles WHERE id = profile_id) = auth.uid());

-- Homeowners policies
CREATE POLICY "Enable read access for all users" ON homeowners FOR SELECT USING (true);
CREATE POLICY "Enable insert for homeowner profiles" ON homeowners FOR INSERT 
  WITH CHECK ((SELECT user_type FROM profiles WHERE id = profile_id) = 'homeowner');
CREATE POLICY "Enable update for own profile" ON homeowners FOR UPDATE 
  USING ((SELECT id FROM profiles WHERE id = profile_id) = auth.uid());

-- Jobs policies
CREATE POLICY "Enable read access for involved parties" ON jobs FOR SELECT 
  USING ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid() 
      OR (SELECT profile_id FROM electricians WHERE id = electrician_id) = auth.uid());
      
CREATE POLICY "Enable insert for homeowners" ON jobs FOR INSERT 
  WITH CHECK ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid());
  
CREATE POLICY "Enable update for involved parties" ON jobs FOR UPDATE 
  USING ((SELECT profile_id FROM homeowners WHERE id = homeowner_id) = auth.uid() 
      OR (SELECT profile_id FROM electricians WHERE id = electrician_id) = auth.uid()); 