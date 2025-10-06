package com.demo.iconsetgeneratordemo.domain;

import com.demo.iconsetgeneratordemo.util.RoaringBitmapConverter;
import jakarta.persistence.*;
import org.roaringbitmap.RoaringBitmap;
import java.time.LocalDateTime;

@Entity
@Table(name = "icon_sets")
public class IconSet {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "hash", nullable = false, unique = true)
    private byte[] hash;

    @Column(name = "icon_bitmap", nullable = false)
    @Convert(converter = RoaringBitmapConverter.class)
//    @Transient
    private RoaringBitmap iconBitmap;

    @Column(name = "size", nullable = false)
    private Integer size;

    @Column(name = "status", nullable = false)
    private String status = "COMPLETED";

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public byte[] getHash() { return hash; }
    public void setHash(byte[] hash) { this.hash = hash; }

    public RoaringBitmap getIconBitmap() { return iconBitmap; }
    public void setIconBitmap(RoaringBitmap iconBitmap) { this.iconBitmap = iconBitmap; }

    public Integer getSize() { return size; }
    public void setSize(Integer size) { this.size = size; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
