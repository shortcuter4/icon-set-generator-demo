package com.demo.iconsetgeneratordemo.service.impl;

import com.demo.iconsetgeneratordemo.domain.Icon;
import com.demo.iconsetgeneratordemo.dto.IconRequest;
import com.demo.iconsetgeneratordemo.dto.IconResponse;
import com.demo.iconsetgeneratordemo.repository.IconRepository;
import com.demo.iconsetgeneratordemo.repository.TagRepository;
import com.demo.iconsetgeneratordemo.service.IconService;
import com.demo.iconsetgeneratordemo.service.internal.MinioService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

/**
 * Implementation of the {@link IconService} that handles uploading icons,
 * storing them in MinIO, saving their metadata to the database, and linking
 * them with corresponding tags.
 *
 * <p>This service performs the following operations:
 * <ul>
 *   <li>Uploads icon files to a MinIO bucket.</li>
 *   <li>Stores icon metadata (category, file path, format) in the database.</li>
 *   <li>Creates or retrieves tags associated with the uploaded icon.</li>
 * </ul>
 *
 * @author  Subhan Ibrahimli
 * @since   04.10.2025
 * @version 1.0
 */

@Service
@RequiredArgsConstructor
@Slf4j
public class IconServiceImpl implements IconService {

    private final MinioService minioService;
    private final IconRepository iconRepository;
    private final TagRepository tagRepository;

    @Value("minio.bucket-name")
    private String icon_bucket;

    @Override
    @Transactional
    public IconResponse uploadIcon(IconRequest request, MultipartFile file) {
        try {
            String format = getExtension(file.getOriginalFilename());

            // TODO: upload file to MinIO first
            String objectName = request.category() + "/" + System.currentTimeMillis() + "." + format;
            String filePath = minioService.uploadFile(icon_bucket, objectName, file);

            // TODO: save icon metadata with filePath
            Icon icon = new Icon();
            icon.setCategory(request.category());
            icon.setFileFormat(format);
            icon.setFilePath(filePath);

            Icon savedIcon = iconRepository.save(icon);

            Long iconId = savedIcon.getId();

            // TODO: save tags
            for (String tagName : request.tags()) {
                Long tagId = tagRepository.findOrCreate(tagName);
                iconRepository.insertIconTag(iconId, tagId);
            }

            return new IconResponse(iconId, filePath, request.tags(), request.category());

        } catch (Exception e) {
            log.error("Failed to upload icon", e);
            throw new RuntimeException(e);
        }
    }

    private String getExtension(String filename) {
        int dotIndex = filename.lastIndexOf(".");
        return (dotIndex == -1) ? "" : filename.substring(dotIndex + 1).toLowerCase();
    }
}
