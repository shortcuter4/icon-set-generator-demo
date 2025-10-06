package com.demo.iconsetgeneratordemo.repository;

import com.demo.iconsetgeneratordemo.domain.Icon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface IconRepository extends JpaRepository<Icon, Long> {
    @Modifying
    @Query(
            value = "" +
                    "INSERT INTO icon_tags(icon_id, tag_id) " +
                    "VALUES (:iconId, :tagId) " +
                    "ON CONFLICT DO NOTHING" +
                    "",
            nativeQuery = true
    )
    void insertIconTag(
            @Param("iconId") Long iconId,
            @Param("tagId") Long tagId
    );
}
