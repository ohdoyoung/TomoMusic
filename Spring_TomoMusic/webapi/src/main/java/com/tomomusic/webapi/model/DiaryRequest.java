package com.tomomusic.webapi.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DiaryRequest {
    private String loginId; // 사용자 아이디
    private String content; // 일기 내용
    private List<String> emotions;

}