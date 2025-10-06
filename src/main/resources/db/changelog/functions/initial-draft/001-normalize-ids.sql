CREATE OR REPLACE FUNCTION normalize_icon_ids(p_icon_ids BIGINT[])
RETURNS BIGINT[] AS $$
BEGIN
RETURN (SELECT array_agg(id ORDER BY id)
        FROM unnest(p_icon_ids) AS id);
END;
$$ LANGUAGE plpgsql IMMUTABLE;
