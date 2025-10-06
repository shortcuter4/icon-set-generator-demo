--liquibase formatted sql

--changeset architect:1
DROP TABLE IF EXISTS icon_set_attempts CASCADE;
DROP TABLE IF EXISTS posting_table CASCADE;
DROP TABLE IF EXISTS set_members CASCADE;
DROP TABLE IF EXISTS icon_sets CASCADE;
DROP TABLE IF EXISTS icon_tags CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS icons CASCADE;

CREATE EXTENSION IF NOT EXISTS roaringbitmap;
CREATE EXTENSION IF NOT EXISTS pgcrypto;


--changeset architect:2
CREATE TABLE icons (
                       icon_id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(255),
                       file_path TEXT,
                       file_format VARCHAR(16) NOT NULL,
                       category VARCHAR(225),
                       created_at TIMESTAMPTZ DEFAULT NOW()
);

--changeset architect:3
CREATE TABLE tags (
                      tag_id BIGSERIAL PRIMARY KEY,
                      name VARCHAR(255) NOT NULL UNIQUE
);

--changeset architect:4
CREATE TABLE icon_tags (
                           icon_id BIGINT NOT NULL,
                           tag_id BIGINT NOT NULL,
                           PRIMARY KEY (icon_id, tag_id),
                           FOREIGN KEY (icon_id) REFERENCES icons(icon_id) ON DELETE CASCADE,
                           FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

--changeset architect:5
CREATE TABLE icon_sets (
                           set_id BIGSERIAL PRIMARY KEY,
                           icon_ids BIGINT[] NOT NULL,       -- Postgres array of icon_ids (canonical sorted order)
                           set_hash BYTEA NOT NULL,          -- SHA256 (or similar) of sorted icon_ids
                           roaring_bitmap roaringbitmap NOT NULL,    -- compressed bitmap for overlap/intersection queries
                                                             -- (compressed bitmap of icon_ids)
                           status VARCHAR(20),
                           created_at TIMESTAMPTZ DEFAULT NOW(),
                           UNIQUE(set_hash)                  -- prevents duplicates (permutation check)
);

--changeset architect:6
CREATE TABLE set_members (
                             set_id BIGINT NOT NULL,
                             icon_id BIGINT NOT NULL,
                             position SMALLINT NOT NULL,
                             status VARCHAR(20),
                             PRIMARY KEY (set_id, icon_id),
                             FOREIGN KEY (set_id) REFERENCES icon_sets(set_id) ON DELETE CASCADE,
                             FOREIGN KEY (icon_id) REFERENCES icons(icon_id) ON DELETE CASCADE
);

--changeset architect:7
CREATE TABLE posting_table (
                               icon_id BIGINT PRIMARY KEY,
                               set_ids BIGINT[],
                               set_bitmap roaringbitmap NOT NULL
);

--changeset architect:8
CREATE TABLE icon_set_attempts (
                                   attempt_id BIGSERIAL PRIMARY KEY,
                                   icon_ids BIGINT[] NOT NULL,
                                   set_hash BYTEA NOT NULL,
                                   worker_id TEXT,
                                   status VARCHAR(30) NOT NULL,
                                   reason TEXT,
                                   created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

--changeset architect:9
-- indexes to speed common lookups
CREATE INDEX idx_set_members_set ON set_members (set_id);
CREATE INDEX idx_icon_tags_tag ON icon_tags (tag_id);
CREATE INDEX idx_icons_file_format ON icons (file_format);

CREATE SEQUENCE attempt_id_seq START 1;
CREATE SEQUENCE icon_id_seq START 1;
CREATE SEQUENCE icon_set_id_seq START 1;
CREATE SEQUENCE tag_id_seq START 1;
