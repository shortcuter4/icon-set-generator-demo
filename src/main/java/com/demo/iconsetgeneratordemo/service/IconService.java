package com.demo.iconsetgeneratordemo.service;

import com.demo.iconsetgeneratordemo.dto.IconRequest;
import com.demo.iconsetgeneratordemo.dto.IconResponse;
import org.springframework.web.multipart.MultipartFile;

public interface IconService {
    IconResponse uploadIcon(IconRequest request, MultipartFile file);
}
