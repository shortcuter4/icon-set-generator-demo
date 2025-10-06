-- ============================================
-- HELPER FUNCTION: rb_from_array
-- Build a roaring bitmap from an integer array
-- ============================================
CREATE OR REPLACE FUNCTION rb_from_array(input BIGINT[])
    RETURNS roaringbitmap AS $$
BEGIN
    -- Cast BIGINT[] -> INT[] safely
    RETURN rb_build(ARRAY(SELECT unnest(input)::INT));
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- HELPER AGGREGATE: rb_union_agg
-- Union multiple roaring bitmaps
-- ============================================
DROP AGGREGATE IF EXISTS rb_union_agg(roaringbitmap);

CREATE AGGREGATE rb_union_agg(roaringbitmap) (
    SFUNC = rb_or,
    STYPE = roaringbitmap
    );

-- ============================================
-- FUNCTION: normalize_icon_ids
-- Sort IDs for canonical order
-- ============================================
CREATE OR REPLACE FUNCTION normalize_icon_ids(p_icon_ids BIGINT[])
    RETURNS BIGINT[] AS $$
BEGIN
    RETURN (SELECT array_agg(id ORDER BY id)
            FROM unnest(p_icon_ids) AS id);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- FUNCTION: generate_set_hash
-- SHA256 hash of sorted IDs
-- ============================================
CREATE OR REPLACE FUNCTION generate_set_hash(p_sorted_icon_ids BIGINT[])
    RETURNS BYTEA AS $$
BEGIN
    RETURN digest(array_to_string(p_sorted_icon_ids, ','), 'sha256');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- FUNCTION: is_duplicate_set
-- ============================================
CREATE OR REPLACE FUNCTION is_duplicate_set(p_hash BYTEA)
    RETURNS BOOLEAN AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM icon_sets
    WHERE hash = p_hash;

    RETURN v_count > 0;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- FUNCTION: has_excessive_overlap
-- ============================================
CREATE OR REPLACE FUNCTION has_excessive_overlap(
    p_icon_ids BIGINT[],
    p_overlap_threshold NUMERIC
)
    RETURNS BOOLEAN AS $$
DECLARE
    existing_bitmap roaringbitmap;
    intersect_count INT;
    total_count INT := array_length(p_icon_ids, 1);
BEGIN
    -- Union all existing sets of candidate icons
    SELECT rb_union_agg(set_ids_bitmap) INTO existing_bitmap
    FROM icon_set_items
    WHERE icon_id = ANY(p_icon_ids);

    -- Count how many candidate icons already appear in sets
    SELECT COUNT(*) INTO intersect_count
    FROM icon_set_items
    WHERE icon_id = ANY(p_icon_ids)
      AND set_ids_bitmap IS NOT NULL;

    RETURN (intersect_count::NUMERIC / total_count) > p_overlap_threshold;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- FUNCTION: generate_set_from_tags
-- ============================================
CREATE OR REPLACE FUNCTION generate_icon_set_from_tags(
    p_tag_ids BIGINT[],
    p_set_size INTEGER,
    p_overlap_threshold NUMERIC DEFAULT 0.3
)
    RETURNS BIGINT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_set_id BIGINT;
    v_candidate_ids BIGINT[];
    v_sorted_ids BIGINT[];
    v_hash BYTEA;
    v_bitmap roaringbitmap;
    v_candidate_bitmap roaringbitmap;
    v_max_overlap INT := 0;
    v_lock_key BIGINT;
BEGIN
    --Acquire advisory lock
    v_lock_key := ('x' || substring(md5(array_to_string(p_tag_ids, ',')), 1, 15))::bit(60)::bigint;
    PERFORM pg_advisory_xact_lock(v_lock_key);

    -- Select random candidate icons - PROPERLY FIXED
    WITH distinct_icons AS (
        SELECT DISTINCT i.id, random() AS rand
        FROM icons i
                 JOIN icon_tags it ON i.id = it.icon_id
        WHERE it.tag_id = ANY(p_tag_ids)
    )
    SELECT array_agg(id)
    INTO v_candidate_ids
    FROM (
             SELECT id
             FROM distinct_icons
             ORDER BY rand
             LIMIT p_set_size
         ) AS randomized;

    -- Fail if not enough icons
    IF v_candidate_ids IS NULL OR array_length(v_candidate_ids, 1) < p_set_size THEN
        RETURN NULL;
    END IF;

    -- Normalize icon IDs
    SELECT array_agg(id ORDER BY id)
    INTO v_sorted_ids
    FROM unnest(v_candidate_ids) AS id;

    -- Generate SHA256 hash
    v_hash := digest(array_to_string(v_sorted_ids, ','), 'sha256');

    -- Check duplicate set by hash
    IF EXISTS (SELECT 1 FROM icon_sets WHERE hash = v_hash) THEN
        RETURN NULL;
    END IF;

    -- Check excessive overlap
    v_candidate_bitmap := rb_from_array(v_sorted_ids);

    SELECT MAX(rb_and_cardinality(v_candidate_bitmap, icon_bitmap))
    INTO v_max_overlap
    FROM icon_sets;

    v_max_overlap := COALESCE(v_max_overlap, 0);

    IF v_max_overlap > CEIL(array_length(v_sorted_ids, 1) * p_overlap_threshold) THEN
        RETURN NULL;
    END IF;

    -- Use the bitmap already created
    v_bitmap := v_candidate_bitmap;

    -- Insert into icon_sets
    INSERT INTO icon_sets(hash, icon_bitmap, size, status, created_at)
    VALUES (v_hash, v_bitmap, array_length(v_sorted_ids, 1), 'COMPLETED', now())
    RETURNING id INTO v_set_id;

    -- Insert new rows OR update existing rows
    INSERT INTO icon_set_items(icon_id, set_ids_bitmap)
    SELECT id, rb_from_array(ARRAY[v_set_id])
    FROM unnest(v_sorted_ids) AS id
    ON CONFLICT (icon_id)
        DO UPDATE SET
        set_ids_bitmap = rb_or(icon_set_items.set_ids_bitmap, EXCLUDED.set_ids_bitmap);

    -- Return new set ID
    RETURN v_set_id;
END;
$$;