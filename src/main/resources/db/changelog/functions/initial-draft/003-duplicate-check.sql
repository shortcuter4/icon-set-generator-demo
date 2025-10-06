CREATE OR REPLACE FUNCTION is_duplicate_set(p_icon_ids BIGINT[])
RETURNS BOOLEAN AS $$
DECLARE
v_hash BYTEA;
BEGIN
    v_hash := generate_set_hash(p_icon_ids);
RETURN EXISTS (SELECT 1 FROM icon_sets WHERE set_hash = v_hash);
END;
$$ LANGUAGE plpgsql;
