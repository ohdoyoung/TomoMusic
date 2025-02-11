package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tomomusic.webapi.Service.DiaryService;
import com.tomomusic.webapi.model.DiaryRequest;

import java.time.LocalDate;

@RestController
@RequestMapping("/api")
public class DiaryController {

    @Autowired
    private DiaryService diaryService; // 일기 서비스

    // 일기 저장 API
    @PostMapping("/saveDiary")
    public ResponseEntity<String> saveDiary(@RequestBody DiaryRequest diaryRequest) {
        try {
            // 받은 데이터 처리
            String userId = diaryRequest.getLoginId();
            String content = diaryRequest.getDiaryContent();
            LocalDate date = LocalDate.now(); // 오늘 날짜

            // 일기 저장 서비스 호출
            boolean isSaved = diaryService.saveDiary(userId, content, date);

            if (isSaved) {
                return ResponseEntity.ok("일기 저장 성공");
            } else {
                return ResponseEntity.status(500).body("일기 저장 실패");
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("서버 오류: " + e.getMessage());
        }
    }
}