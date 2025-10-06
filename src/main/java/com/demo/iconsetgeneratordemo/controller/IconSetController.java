package com.demo.iconsetgeneratordemo.controller;

import com.demo.iconsetgeneratordemo.dto.IconSetRequest;
import com.demo.iconsetgeneratordemo.dto.IconSetResponse;
import com.demo.iconsetgeneratordemo.service.IconSetGeneratorService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/icon-sets")
@RequiredArgsConstructor
public class IconSetController {

    private final IconSetGeneratorService iconSetGeneratorService;

    @PostMapping("/generate")
    public IconSetResponse generateIconSet(@RequestBody IconSetRequest request) {
        return iconSetGeneratorService.generateSet(request);
    }
}
