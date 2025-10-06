package com.demo.iconsetgeneratordemo.service.impl;

import com.demo.iconsetgeneratordemo.dto.IconSetRequest;
import com.demo.iconsetgeneratordemo.dto.IconSetResponse;
import com.demo.iconsetgeneratordemo.repository.IconSetRepository;
import com.demo.iconsetgeneratordemo.service.IconSetGeneratorService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * Implementation of the {@link IconSetGeneratorService} responsible for generating
 * icon sets based on provided tags, desired set size, and similarity threshold.
 *
 * <p>This service acts as a bridge between the application layer and the database layer.
 * It delegates the actual icon set generation logic to a PostgreSQL stored function
 * that computes unique icon sets according to the given parameters.
 *
 * <p>Core responsibilities:
 * <ul>
 *   <li>Validate and process the incoming {@link IconSetRequest}</li>
 *   <li>Invoke the database function to generate an icon set</li>
 *   <li>Return a structured {@link IconSetResponse} indicating success or failure</li>
 * </ul>
 *
 * @author  Subhan Ibrahimli
 * @since   04.10.2025
 * @version 1.0
 */

@Service
@RequiredArgsConstructor
public class IconSetGeneratorServiceImpl implements IconSetGeneratorService {

    private final IconSetRepository iconSetRepository;

    @Override
    public IconSetResponse generateSet(IconSetRequest iconSetRequest) {
        try {
            Long[] tagIdsArray = iconSetRequest.tagIds().toArray(new Long[0]);

            Long setId = iconSetRepository.generateSetFromTags(
                    tagIdsArray,
                    iconSetRequest.setSize(),
                    iconSetRequest.threshold()
            );

            if (setId == null) {
                return new IconSetResponse(null, "FAILED_OR_DUPLICATE_OR_OVERLAP");
            }
            return new IconSetResponse(setId, "SUCCESS");

        } catch (Exception ex) {
            return new IconSetResponse(null, "ERROR: " + ex.getMessage());
        }
    }


}
