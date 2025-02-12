package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tomomusic.webapi.Service.DiaryService;
import com.tomomusic.webapi.entity.Diary;
import com.tomomusic.webapi.model.DiaryRequest;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api")
public class DiaryController {

    @Autowired
    private DiaryService diaryService;

    // // 일기 저장 (이모지 포함)
    // @PostMapping("/saveDiary")
    // public ResponseEntity<?> saveDiary(@RequestBody DiaryRequest diaryRequest) {
    // Diary diary = new Diary();
    // diary.setLoginId(diaryRequest.getLoginId()); // 사용자 아이디 설정
    // diary.setContent(diaryRequest.getContent()); // 일기 내용 설정
    // diary.setEmotions(diaryRequest.getEmotions()); // 이모지 JSON 처리
    // diary.setCreatedAt(LocalDateTime.now()); // 생성 일시 설정
    // diary.setUpdatedAt(LocalDateTime.now()); // 수정 일시 설정

    // diaryService.saveDiary(diary); // DiaryService를 통해 저장
    // return ResponseEntity.ok().build(); // 저장 성공 응답
    // }

    @PostMapping("/saveDiary")
    public Diary saveDiary(@RequestBody Diary diary) {
        return diaryService.saveDiary(diary);
    }

    // 특정 날짜에 대한 일기 조회 (사용자 아이디 + 날짜)
    @GetMapping("/entry")
    public ResponseEntity<Diary> getDiaryEntry(@RequestParam String loginId, @RequestParam String date) {
        LocalDate entryDate = LocalDate.parse(date); // "YYYY-MM-DD" 형식의 문자열을 LocalDate로 변환
        Diary diary = diaryService.getDiaryByUserAndDate(loginId, entryDate); // 해당 일기 조회
        System.out.println(diary);
        return ResponseEntity.ok(diary); // 조회된 일기 반환
    }

    // 사용자가 작성한 모든 일기 조회 (앨범/트랙 정보 포함)
    @GetMapping("/entries")
    public ResponseEntity<List<Diary>> getAllDiaryEntries(@RequestParam String loginId) {
        List<Diary> diaries = diaryService.getAllDiariesByUser(loginId); // 사용자에 해당하는 모든 일기 조회
        return ResponseEntity.ok(diaries); // 조회된 모든 일기 반환
    }
}