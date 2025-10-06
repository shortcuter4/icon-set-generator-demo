package com.demo.iconsetgeneratordemo.dto;

import com.demo.iconsetgeneratordemo.domain.Tag;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class Payload {
    private List<Tag> tags;
    private String iconName;
    private String category;
}
