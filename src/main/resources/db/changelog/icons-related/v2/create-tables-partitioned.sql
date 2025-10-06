-- extensions
CREATE EXTENSION IF NOT EXISTS roaringbitmap;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- icons
CREATE TABLE IF NOT EXISTS icons (
             id BIGSERIAL PRIMARY KEY,
             name TEXT NOT NULL,
             category TEXT,
             file_path TEXT NOT NULL,
             created_at TIMESTAMP DEFAULT now()
    );

-- tags
CREATE TABLE IF NOT EXISTS tags (
            id BIGSERIAL PRIMARY KEY,
            name TEXT UNIQUE NOT NULL
);

-- icon_tags (many-to-many)
CREATE TABLE IF NOT EXISTS icon_tags (
            icon_id BIGINT NOT NULL REFERENCES icons(id) ON DELETE CASCADE,
            tag_id BIGINT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
            PRIMARY KEY (icon_id, tag_id)
    );

-- icon sets
CREATE TABLE IF NOT EXISTS icon_sets (
            id BIGSERIAL PRIMARY KEY,
            hash BYTEA NOT NULL UNIQUE,
            icon_bitmap BYTEA NOT NULL,
            created_at TIMESTAMP DEFAULT now()
    );

-- icon set items (partitioned by hash modulo 4)
CREATE TABLE IF NOT EXISTS icon_set_items (
            icon_id BIGINT NOT NULL REFERENCES icons(id) ON DELETE CASCADE,
            set_ids_bitmap BYTEA NOT NULL,
            positions INT[],  -- optional, nullable
            PRIMARY KEY (icon_id)
    ) PARTITION BY LIST ((icon_id % 4));

-- Partitions
CREATE TABLE IF NOT EXISTS icon_set_items_part0 PARTITION OF icon_set_items FOR VALUES IN (0);
CREATE TABLE IF NOT EXISTS icon_set_items_part1 PARTITION OF icon_set_items FOR VALUES IN (1);
CREATE TABLE IF NOT EXISTS icon_set_items_part2 PARTITION OF icon_set_items FOR VALUES IN (2);
CREATE TABLE IF NOT EXISTS icon_set_items_part3 PARTITION OF icon_set_items FOR VALUES IN (3);

-- Indexes on partitions
CREATE INDEX IF NOT EXISTS idx_icon_set_items_part0_icon_id ON icon_set_items_part0(icon_id);
CREATE INDEX IF NOT EXISTS idx_icon_set_items_part1_icon_id ON icon_set_items_part1(icon_id);
CREATE INDEX IF NOT EXISTS idx_icon_set_items_part2_icon_id ON icon_set_items_part2(icon_id);
CREATE INDEX IF NOT EXISTS idx_icon_set_items_part3_icon_id ON icon_set_items_part3(icon_id);

-- Indexes on icon_tags
CREATE INDEX IF NOT EXISTS idx_icon_tags_icon_id ON icon_tags(icon_id);
CREATE INDEX IF NOT EXISTS idx_icon_tags_tag_id ON icon_tags(tag_id);
