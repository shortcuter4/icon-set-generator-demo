package com.demo.iconsetgeneratordemo.domain;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "icon_tags")
@IdClass(IconTagId.class)
@Getter
@Setter
public class IconTag {
    @Id
    @Column(name = "icon_id")
    private Long iconId;

    @Id
    @Column(name = "tag_id")
    private Long tagId;

}