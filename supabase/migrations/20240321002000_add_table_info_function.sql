-- Create function to get table information
CREATE OR REPLACE FUNCTION get_table_info(table_name text)
RETURNS TABLE (
    column_name text,
    data_type text,
    is_nullable boolean,
    column_default text
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.column_name::text,
        c.data_type::text,
        (c.is_nullable = 'YES') as is_nullable,
        c.column_default::text
    FROM information_schema.columns c
    WHERE c.table_schema = 'public'
    AND c.table_name = $1
    ORDER BY c.ordinal_position;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create schema for linting if it doesn't exist
CREATE SCHEMA IF NOT EXISTS lint;

-- Create table bloat detection view
CREATE OR REPLACE VIEW lint.table_bloat AS
WITH constants AS (
    SELECT current_setting('block_size')::numeric AS bs, 23 AS hdr, 4 AS ma
),
bloat_info AS (
    SELECT
        ma,
        bs,
        schemaname,
        tablename,
        (datawidth + (hdr + ma - (CASE WHEN hdr % ma = 0 THEN ma ELSE hdr % ma END)))::numeric AS datahdr,
        (maxfracsum * (nullhdr + ma - (CASE WHEN nullhdr % ma = 0 THEN ma ELSE nullhdr % ma END))) AS nullhdr2
    FROM (
        SELECT
            schemaname,
            tablename,
            hdr,
            ma,
            bs,
            SUM((1 - null_frac) * avg_width) AS datawidth,
            MAX(null_frac) AS maxfracsum,
            hdr + (
                SELECT 1 + count(*) / 8
                FROM pg_stats s2
                WHERE null_frac <> 0
                AND s2.schemaname = s.schemaname
                AND s2.tablename = s.tablename
            ) AS nullhdr
        FROM pg_stats s, constants
        GROUP BY 1, 2, 3, 4, 5
    ) AS foo
),
table_bloat AS (
    SELECT
        schemaname,
        tablename,
        cc.relpages,
        bs,
        CEIL((cc.reltuples * ((datahdr + ma -
          (CASE WHEN datahdr % ma = 0 THEN ma ELSE datahdr % ma END)) + nullhdr2 + 4)) / (bs - 20::float)) AS otta
    FROM
        bloat_info
        JOIN pg_class cc ON cc.relname = bloat_info.tablename
        JOIN pg_namespace nn ON cc.relnamespace = nn.oid
            AND nn.nspname = bloat_info.schemaname
            AND nn.nspname <> 'information_schema'
    WHERE
        cc.relkind = 'r'
        AND cc.relam = (SELECT oid FROM pg_am WHERE amname = 'heap')
)
SELECT
    schemaname,
    tablename,
    ROUND(
        CASE 
            WHEN otta = 0 THEN 0.0 
            ELSE relpages/otta::numeric 
        END, 
    1) AS bloat_factor,
    CASE 
        WHEN relpages < otta THEN 0 
        ELSE (bs * (relpages-otta)::bigint)::bigint 
    END AS bloat_size
FROM table_bloat
WHERE schemaname NOT IN (
    '_timescaledb_cache', '_timescaledb_catalog', '_timescaledb_config', 
    '_timescaledb_internal', 'information_schema', 'pg_catalog'
); 