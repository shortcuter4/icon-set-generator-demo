package com.demo.iconsetgeneratordemo.controller;

import com.demo.iconsetgeneratordemo.domain.Tag;
import com.demo.iconsetgeneratordemo.dto.*;
import com.demo.iconsetgeneratordemo.service.IconService;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;


@RestController
@RequestMapping("/api/v1/icons")
@RequiredArgsConstructor
public class IconController {

    private final IconService iconService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<IconResponse> uploadIcon(
            @RequestPart("metadata") String metadataJson,
            @RequestPart("file") MultipartFile file ) throws Exception {

        ObjectMapper mapper = new ObjectMapper();
        Payload metadata = mapper.readValue(metadataJson, Payload.class);

        IconRequest iconRequest = new IconRequest(
                metadata.getIconName(),
                metadata.getCategory(),
                metadata.getTags().stream().map(Tag::getName).toList()
        );

        IconResponse response = iconService.uploadIcon(iconRequest, file);
        return ResponseEntity.ok(response);
    }
}

