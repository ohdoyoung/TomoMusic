package com.tomomusic.webapi.Service;

import com.tomomusic.webapi.entity.Diary;
import com.tomomusic.webapi.mapper.DiaryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class DiaryService {

    @Autowired
    private DiaryRepository diaryRepository;

    // 일기 저장
    public Diary saveDiary(Diary diary) {
        // JSON 형식으로 `emotions` 리스트를 저장
        return diaryRepository.save(diary);
    }

    // 사용자 아이디와 날짜로 일기 조회
    public Diary getDiaryByUserAndDate(String userId, LocalDate date) {
        return diaryRepository.findByLoginIdAndCreatedAt(userId, date); // 로그인 아이디와 날짜로 일기 조회
    }

    // 사용자 아이디로 모든 일기 조회
    public List<Diary> getAllDiariesByUser(String userId) {
        return diaryRepository.findByLoginId(userId); // 로그인 아이디로 모든 일기 조회
    }
}