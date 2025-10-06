--liquibase formatted sql
-- changeset subhan:004-create-icon-tags
CREATE TABLE icon_tags (
                           icon_id BIGINT NOT NULL,
                           tag_id BIGINT NOT NULL,
                           PRIMARY KEY (icon_id, tag_id),
                           CONSTRAINT fk_icon_tags_icon FOREIGN KEY (icon_id) REFERENCES icons(id) ON DELETE CASCADE,
                           CONSTRAINT fk_icon_tags_tag FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);