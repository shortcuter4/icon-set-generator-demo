-- =====================================================
-- Author: Subhan Ibrahimli
-- Description: Create icon_sets table with sequence
-- =====================================================

-- changeset subhan:002-create-icon-sets
CREATE SEQUENCE icon_set_id_seq START WITH 1 INCREMENT BY 1;

-- Create table with id using the sequence
CREATE TABLE icon_sets (
                           id BIGINT PRIMARY KEY DEFAULT nextval('icon_set_id_seq'),
                           name VARCHAR(255),
                           canonical_sha256 VARCHAR(64) NOT NULL,
                           roaring_bitmap BYTEA,
                           created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create unique and normal indexes
CREATE UNIQUE INDEX idx_icon_sets_hash ON icon_sets(canonical_sha256);
CREATE INDEX idx_icon_sets_created_at ON icon_sets(created_at);
