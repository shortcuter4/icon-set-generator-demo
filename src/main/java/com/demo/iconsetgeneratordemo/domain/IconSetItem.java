package com.demo.iconsetgeneratordemo.domain;

import com.demo.iconsetgeneratordemo.util.RoaringBitmapConverter;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.roaringbitmap.RoaringBitmap;

@Entity
@Table(name = "icon_set_items")
public class IconSetItem {

    @Id
    @Column(name = "icon_id")
    private Long iconId;

    @Column(name = "set_ids_bitmap", nullable = false)
    @Convert(converter = RoaringBitmapConverter.class)
//    @Transient
    private RoaringBitmap setIdsBitmap;

    @JdbcTypeCode(SqlTypes.ARRAY)
    @Column(name = "positions")
    private Integer[] positions;  // stored as INT[] in PostgreSQL


    public Long getIconId() { return iconId; }
    public void setIconId(Long iconId) { this.iconId = iconId; }

    public RoaringBitmap getSetIdsBitmap() { return setIdsBitmap; }
    public void setSetIdsBitmap(RoaringBitmap setIdsBitmap) { this.setIdsBitmap = setIdsBitmap; }

    public Integer[] getPositions() { return positions; }
    public void setPositions(Integer[] positions) { this.positions = positions; }
}

