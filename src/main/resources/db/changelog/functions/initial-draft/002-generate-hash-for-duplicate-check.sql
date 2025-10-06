
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION generate_set_hash(p_icon_ids BIGINT[])
    RETURNS BYTEA AS $$
DECLARE
    v_sorted BIGINT[];
BEGIN
    v_sorted := normalize_icon_ids(p_icon_ids);
    RETURN digest(array_to_string(v_sorted, ','), 'sha256');
END;
$$ LANGUAGE plpgsql IMMUTABLE;
