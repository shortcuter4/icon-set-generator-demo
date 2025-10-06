package com.demo.iconsetgeneratordemo.repository;

import com.demo.iconsetgeneratordemo.domain.IconSet;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

@Repository
public interface IconSetRepository extends JpaRepository<IconSet, Long> {
    @Query(
            value = """
            SELECT generate_icon_set_from_tags(
            CAST(:tagIds AS bigint[]), 
            CAST(:gridSize AS int), 
            CAST(:threshold AS numeric)
                   )
            """,
            nativeQuery = true
    )
    Long generateSetFromTags(
            @Param("tagIds") Long[] tagIds,
            @Param("gridSize") Integer gridSize,
            @Param("threshold") BigDecimal threshold
    );

}
