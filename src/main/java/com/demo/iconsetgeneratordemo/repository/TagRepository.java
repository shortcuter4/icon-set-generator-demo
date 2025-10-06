package com.demo.iconsetgeneratordemo.repository;

import com.demo.iconsetgeneratordemo.domain.Tag;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
public interface TagRepository extends JpaRepository<Tag, Long> {
    @Query(value = "" +
            "SELECT * " +
            "FROM tags " +
            "WHERE name = :name" +
            "",
            nativeQuery = true)
    Optional<Tag> findByName(@Param("name") String name);

   default Long findOrCreate(String name) {
        return findByName(name)
                .map(Tag::getId)
                .orElseGet(() -> {
                    Tag tag = new Tag();
                    tag.setName(name);
                    return save(tag).getId();
                });
    }
}
