package com.tomomusic.webapi.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Diary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String loginId; // 사용자 아이디
    private String content; // 일기 내용
    private LocalDate date; // 작성 날짜

    public Diary(String loginId, String content, LocalDate date) {
        this.loginId = loginId;
        this.content = content;
        this.date = date;
    }

}