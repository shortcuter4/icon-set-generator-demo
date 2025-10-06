-- extensions
CREATE EXTENSION IF NOT EXISTS roaringbitmap;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- icons
CREATE TABLE IF NOT EXISTS icons (
        id BIGSERIAL PRIMARY KEY,
        name TEXT GENERATED ALWAYS AS (id::text) STORED,
        category TEXT,
        file_format TEXT,
        file_path TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT now()
);

-- tags (dictionary)
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
         icon_bitmap roaringbitmap NOT NULL,  -- store roaring bitmap of the set (icon IDs)
         size INT NOT NULL,
         status TEXT NOT NULL DEFAULT 'COMPLETED',-- generation status
         created_at TIMESTAMP DEFAULT now()
);

-- ICON SET ITEMS
CREATE TABLE IF NOT EXISTS icon_set_items (
        icon_id BIGINT NOT NULL REFERENCES icons(id) ON DELETE CASCADE,
        set_ids_bitmap roaringbitmap NOT NULL,  -- store roaring bitmap of set_ids
        positions INT[],  -- optional, nullable
        PRIMARY KEY (icon_id)
);

CREATE TABLE IF NOT EXISTS icon_set_relations (
                                                  set_id BIGINT NOT NULL REFERENCES icon_sets(id) ON DELETE CASCADE,
                                                  icon_id BIGINT NOT NULL REFERENCES icons(id) ON DELETE CASCADE,
                                                  PRIMARY KEY (set_id, icon_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_icon_tags_icon_id ON icon_tags(icon_id);
CREATE INDEX IF NOT EXISTS idx_icon_tags_tag_id ON icon_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_icon_set_items_icon_id ON icon_set_items(icon_id);
