-- Ensure hash uniqueness
DO $$
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM pg_constraint
            WHERE conname = 'unique_set_hash'
        ) THEN
            ALTER TABLE icon_sets
                ADD CONSTRAINT unique_set_hash UNIQUE (set_hash);
        END IF;
    END
$$;

CREATE OR REPLACE FUNCTION generate_icon_set_from_tags(
    p_tag_ids BIGINT[],
    p_set_size INTEGER,
    p_overlap_threshold NUMERIC DEFAULT 0.3
) RETURNS BIGINT
    LANGUAGE plpgsql
AS $$
DECLARE
    v_set_id BIGINT;
    v_candidate_ids BIGINT[];
    v_sorted BIGINT[];
    v_hash BYTEA;
BEGIN
    -- Global advisory lock to avoid concurrent generation
    PERFORM pg_advisory_xact_lock(987654321);

    -- 1. Pick random candidate icons linked to tags (fixed DISTINCT + ORDER BY)
    SELECT array_agg(icon_id)
    INTO v_candidate_ids
    FROM (
             SELECT i.icon_id
             FROM (
                      SELECT DISTINCT i.icon_id
                      FROM icons i
                               JOIN icon_tags it ON i.icon_id = it.icon_id
                      WHERE it.tag_id = ANY(p_tag_ids)
                  ) i
             ORDER BY random()
             LIMIT p_set_size
         ) sub;

    -- Not enough icons
    IF v_candidate_ids IS NULL OR array_length(v_candidate_ids, 1) < p_set_size THEN
        RETURN NULL;
    END IF;

    -- 2. Normalize + hash
    v_sorted := normalize_icon_ids(v_candidate_ids);
    v_hash := generate_set_hash(v_sorted);


    -- 3. Duplicate set check with conflict handling
    INSERT INTO icon_sets(icon_ids, set_hash, status)
    VALUES (v_sorted, v_hash, 'ACTIVE')
    ON CONFLICT (set_hash) DO NOTHING
    RETURNING set_id INTO v_set_id;

    IF v_set_id IS NULL THEN
        -- Set already exists
        RETURN NULL;
    END IF;

    -- 4. Insert set members
    INSERT INTO set_members(set_id, icon_id, position, status)
    SELECT v_set_id, id, row_number() OVER (), 'ACTIVE'
    FROM unnest(v_sorted) AS id;

    -- 5. Update posting_table safely
    FOR i IN 1..array_length(v_sorted, 1) LOOP
            PERFORM pg_advisory_xact_lock(v_sorted[i]); -- per-icon lock

            INSERT INTO posting_table(icon_id, set_ids)
            VALUES (v_sorted[i], ARRAY[v_set_id])
            ON CONFLICT (icon_id) DO UPDATE
                SET set_ids = posting_table.set_ids || EXCLUDED.set_ids;
        END LOOP;

    RETURN v_set_id;
END;
$$;

ALTER FUNCTION generate_icon_set_from_tags(bigint[], integer, numeric) OWNER TO admin;
