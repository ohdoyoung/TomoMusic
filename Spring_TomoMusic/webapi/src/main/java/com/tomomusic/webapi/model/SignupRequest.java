package com.tomomusic.webapi.model;

import lombok.Data;

@Data
public class SignupRequest {
    private String username;
    private String password;

    public SignupRequest() {
    } // 기본 생성자 필요
}