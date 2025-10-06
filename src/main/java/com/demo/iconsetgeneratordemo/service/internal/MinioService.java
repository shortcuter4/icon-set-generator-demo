package com.demo.iconsetgeneratordemo.service.internal;

import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;

/**
 *  Service layer that is responsible for handling file uploads to minIO object storage.
 *
 *  @author Subhan Ibrahimli
 *  @since  04.10.2025
 *  @version 1.0
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class MinioService {

    private final MinioClient minioClient;

    /**
     * Uploads a given multipart file to the specified MinIO bucket.
     *
     * @param bucket      the target bucket name in MinIO
     * @param objectName  the object name (path) to store the file under
     * @param file        the multipart file to be uploaded
     * @return the object name (path) where the file was stored
     * @throws Exception if any upload or streaming error occurs
     */
    public String uploadFile(String bucket, String objectName, MultipartFile file) throws Exception {
        try (InputStream inputStream = file.getInputStream()) {
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucket)
                            .object(objectName)
                            .stream(inputStream, file.getSize(), -1)
                            .contentType(file.getContentType())
                            .build()
            );
            log.info("File uploaded successfully to bucket {} as {}", bucket, objectName);
            return objectName;
        }
    }
}
