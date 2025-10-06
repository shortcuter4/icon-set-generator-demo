CREATE OR REPLACE FUNCTION has_excessive_overlap(
    p_icon_ids BIGINT[],
    p_threshold NUMERIC
)
    RETURNS BOOLEAN AS $$
DECLARE
    v_sorted BIGINT[];
    v_bitmap roaringbitmap;
    v_size INT;
    v_allowed INT;
BEGIN
    -- Normalize
    v_sorted := normalize_icon_ids(p_icon_ids);
    v_size := array_length(v_sorted, 1);

    -- Max overlap count allowed
    v_allowed := CEIL(v_size * p_threshold);

    -- Build bitmap of candidate icons
    v_bitmap := rb_build(v_sorted::INT[]);

    -- Check if any existing set overlaps more than allowed
    RETURN EXISTS (
        SELECT 1
        FROM icon_sets s
        WHERE rb_and_cardinality(s.roaring_bitmap, v_bitmap) > v_allowed
    );
END;
$$ LANGUAGE plpgsql;
