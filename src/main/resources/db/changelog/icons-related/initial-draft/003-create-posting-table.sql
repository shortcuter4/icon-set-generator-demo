--liquibase formatted sql

-- =====================================================
-- Author: Subhan Ibrahimli
-- Description: Create posting table
-- =====================================================

-- changeset subhan:003-create-posting
CREATE TABLE posting (
                         icon_id BIGINT NOT NULL,
                         set_id BIGINT NOT NULL,
                         PRIMARY KEY (icon_id, set_id),
                         CONSTRAINT fk_posting_icon_set FOREIGN KEY (set_id) REFERENCES icon_sets(id) ON DELETE CASCADE,
                         CONSTRAINT fk_posting_icon FOREIGN KEY (icon_id) REFERENCES icons(id) ON DELETE CASCADE
);

CREATE INDEX idx_posting_icon ON posting(icon_id);

CREATE INDEX idx_posting_set ON posting(set_id);
