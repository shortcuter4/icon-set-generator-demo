package com.demo.iconsetgeneratordemo.dto;

import java.util.List;

public record IconRequest(
        String name,
        String category,
        List<String> tags
) {}
