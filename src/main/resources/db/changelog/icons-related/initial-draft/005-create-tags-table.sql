--liquibase formatted sql
-- changeset subhan:005-create-tags

CREATE TABLE tags (
                      id BIGSERIAL PRIMARY KEY,
                      name VARCHAR(100) UNIQUE NOT NULL
);

CREATE SEQUENCE tag_id_seq START WITH 1 INCREMENT BY 1;