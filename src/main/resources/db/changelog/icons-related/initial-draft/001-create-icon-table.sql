--liquibase formatted sql

-- =====================================================
-- Author: Subhan Ibrahimli
-- Description: Create icons table
-- =====================================================

-- changeset subhan:001-create-icons
CREATE TABLE icons (
                       id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(255) NOT NULL,
                       file_path VARCHAR(255) NOT NULL,
                       file_format VARCHAR(10),
                       category VARCHAR(100),
                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE icon_id_seq START WITH 1 INCREMENT BY 1;

CREATE INDEX idx_icons_category ON icons(category);

-- CREATE INDEX idx_icons_tags ON icons USING GIN (tags);