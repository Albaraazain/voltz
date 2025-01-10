CREATE OR REPLACE FUNCTION create_user_profile(profile_data JSONB, is_electrician BOOLEAN)
RETURNS VOID
SECURITY DEFINER -- This makes the function run with the privileges of the creator
SET search_path = public -- This prevents search_path injection
LANGUAGE plpgsql
AS $$
BEGIN
  IF is_electrician THEN
    INSERT INTO electricians SELECT * FROM jsonb_populate_record(null::electricians, profile_data);
  ELSE
    INSERT INTO homeowners SELECT * FROM jsonb_populate_record(null::homeowners, profile_data);
  END IF;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION create_user_profile(JSONB, BOOLEAN) TO authenticated; 