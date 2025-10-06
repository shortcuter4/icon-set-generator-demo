package com.demo.iconsetgeneratordemo.dto;

import java.math.BigDecimal;
import java.util.List;

public record IconSetRequest(
        List<Long> tagIds,     // user provides tags instead of icons
        Integer setSize,        // optional, number of icons to pick
        BigDecimal threshold
) {}
