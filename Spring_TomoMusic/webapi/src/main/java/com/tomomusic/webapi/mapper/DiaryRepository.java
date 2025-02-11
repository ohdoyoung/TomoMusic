package com.tomomusic.webapi.mapper;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.tomomusic.webapi.entity.Diary;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    // 필요시 추가적인 메소드 정의 가능
    // 특정 사용자의 날짜별 일기 내용과 앨범, 트랙 정보를 반환
    Diary findByLoginIdAndCreatedAt(String loginId, LocalDate createdAt);

    // 사용자 아이디로 모든 일기 조회
    List<Diary> findByLoginId(String loginId);
}