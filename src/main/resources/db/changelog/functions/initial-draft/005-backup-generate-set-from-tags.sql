-- Generate a new icon set by selecting icons linked to given tags
CREATE OR REPLACE FUNCTION generate_icon_set_from_tags(
    p_tag_ids BIGINT[],
    p_set_size INT,
    p_overlap_threshold NUMERIC DEFAULT 0.3
)
    RETURNS BIGINT AS $$
DECLARE
v_set_id BIGINT;
    v_candidate_ids BIGINT[];
    v_sorted BIGINT[];
    v_hash BYTEA;
    v_bitmap roaringbitmap;
BEGIN
    -- 1. Pick random candidate icons linked to the given tags
SELECT array_agg(icon_id ORDER BY icon_id)
INTO v_candidate_ids
FROM (
         SELECT DISTINCT i.icon_id
         FROM icons i
                  JOIN icon_tags it ON i.icon_id = it.icon_id
         WHERE it.tag_id = ANY(p_tag_ids)
         ORDER BY random()
             LIMIT p_set_size
     ) sub;

-- Not enough icons
IF v_candidate_ids IS NULL OR array_length(v_candidate_ids, 1) < p_set_size THEN
        RETURN NULL;
END IF;

    -- 2. Normalize + hash + bitmap
    v_sorted := normalize_icon_ids(v_candidate_ids);
    v_hash   := generate_set_hash(v_sorted);
    v_bitmap := rb_build(v_sorted::INT[]);

    -- 3. Duplicate check (same hash exists)
    IF EXISTS (SELECT 1 FROM icon_sets WHERE set_hash = v_hash) THEN
        RETURN NULL;
END IF;

    -- 4. Overlap check
    IF has_excessive_overlap(v_sorted, p_overlap_threshold) THEN
        RETURN NULL;
END IF;

    -- 5. Insert into icon_sets
INSERT INTO icon_sets(icon_ids, set_hash, roaring_bitmap, status)
VALUES (v_sorted, v_hash, v_bitmap, 'ACTIVE')
    RETURNING set_id INTO v_set_id;

-- 6. Insert set members
INSERT INTO set_members(set_id, icon_id, position, status)
SELECT v_set_id, id, row_number() OVER (), 'ACTIVE'
FROM unnest(v_sorted) AS id;

-- 7. Update posting_table per icon
INSERT INTO posting_table(icon_id, set_ids, set_bitmap)
SELECT id, ARRAY[v_set_id], rb_build(ARRAY[v_set_id]::INT[])
FROM unnest(v_sorted) AS id
    ON CONFLICT (icon_id) DO UPDATE
                                 SET set_ids   = posting_table.set_ids || EXCLUDED.set_ids,
                                 set_bitmap = rb_or(posting_table.set_bitmap, EXCLUDED.set_bitmap);

RETURN v_set_id;
END;
$$ LANGUAGE plpgsql;