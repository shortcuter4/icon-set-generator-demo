package com.demo.iconsetgeneratordemo.domain;

import java.io.Serializable;
import java.util.Objects;

public class IconTagId implements Serializable {
    private Long iconId;
    private Long tagId;

    public IconTagId() {}
    public IconTagId(Long iconId, Long tagId) {
        this.iconId = iconId;
        this.tagId = tagId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof IconTagId that)) return false;
        return Objects.equals(iconId, that.iconId) && Objects.equals(tagId, that.tagId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(iconId, tagId);
    }
}
