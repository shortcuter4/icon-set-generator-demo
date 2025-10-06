package com.demo.iconsetgeneratordemo.service;

import com.demo.iconsetgeneratordemo.dto.IconSetRequest;
import com.demo.iconsetgeneratordemo.dto.IconSetResponse;

public interface IconSetGeneratorService {
    IconSetResponse generateSet(IconSetRequest iconSetRequest);
}
