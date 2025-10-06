//package com.demo.iconsetgeneratordemo.domain;
//
//import jakarta.persistence.*;
//import lombok.Getter;
//import lombok.Setter;
//import org.hibernate.annotations.JdbcTypeCode;
//import org.hibernate.type.SqlTypes;
//
//import java.sql.Timestamp;
//
//@Entity
//@Table(name = "icon_set_attempts")
//@Getter
//@Setter
//public class IconSetAttempt {
//
//    @Id
//    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "attempt_id_seq")
//    @SequenceGenerator(name = "attempt_id_seq", sequenceName = "attempt_id_seq", allocationSize = 1)
//    @Column(name = "attempt_id")
//    private Long id;
//
//    @JdbcTypeCode(SqlTypes.ARRAY)
//    @Column(name = "icon_ids", nullable = false)
//    private Long[] iconIds;
//
//    @Column(name = "set_hash", nullable = false)
//    private byte[] setHash;
//
//    @Column(name = "worker_id")
//    private String workerId;
//
//    @Column(name = "status", nullable = false, length = 30)
//    private String status;
//
//    @Column(name = "reason")
//    private String reason;
//
//    @Column(name = "created_at", updatable = false, insertable = false)
//    private Timestamp createdAt;
//}