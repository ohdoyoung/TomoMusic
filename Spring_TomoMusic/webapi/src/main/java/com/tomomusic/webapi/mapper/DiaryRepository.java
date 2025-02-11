package com.tomomusic.webapi.mapper;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tomomusic.webapi.entity.Diary;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    // 필요시 추가적인 메소드 정의 가능
}