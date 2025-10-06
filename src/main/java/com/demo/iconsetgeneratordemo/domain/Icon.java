package com.demo.iconsetgeneratordemo.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;

@Entity
@Table(name = "icons")
@Getter
@Setter
public class Icon {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "icon_id_seq")
    @SequenceGenerator(name = "icon_id_seq", sequenceName = "icon_id_seq", allocationSize = 1)
    @Column(name = "id")
    private Long id;

    @Column(name = "name", insertable = false, updatable = false)
    private String name;

    @Column(name = "file_path", nullable = true)
    private String filePath;

    @Column(name = "file_format", nullable = false, length = 10)
    private String fileFormat;

    @Column(name = "category")
    private String category;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Timestamp createdAt;

}

