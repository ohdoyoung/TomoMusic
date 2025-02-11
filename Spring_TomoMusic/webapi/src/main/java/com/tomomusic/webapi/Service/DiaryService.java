package com.tomomusic.webapi.Service;

import java.time.LocalDate;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.tomomusic.webapi.entity.Diary;
import com.tomomusic.webapi.mapper.DiaryRepository;

@Service
public class DiaryService {

    @Autowired
    private DiaryRepository diaryRepository; // 일기 저장을 위한 Repository

    // 일기 저장
    public boolean saveDiary(String userId, String content, LocalDate date) {
        try {
            Diary diary = new Diary(userId, content, date);
            diaryRepository.save(diary); // DB에 저장
            return true;
        } catch (Exception e) {
            // 예외 처리 (로그를 남기거나, 실패한 이유를 반환)
            return false;
        }
    }
}