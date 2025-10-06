package com.demo.iconsetgeneratordemo.dto;

import java.util.List;

public record IconResponse(
        Long id,
        String name,
        List<String> tags,
        String category
) {}
