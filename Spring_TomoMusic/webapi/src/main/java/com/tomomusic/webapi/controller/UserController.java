package com.tomomusic.webapi.controller;

import com.tomomusic.webapi.Service.UserService;
import com.tomomusic.webapi.entity.UserEntity;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserService userService;

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<String> signup(@RequestParam String loginId,
            @RequestParam String password,
            @RequestParam String nickname) {
        System.out.println("loginId: " + loginId);
        System.out.println("password: " + password);
        System.out.println("nickname: " + nickname);

        userService.register(loginId, password, nickname);
        return ResponseEntity.ok("회원가입 성공!");
    }

    // 로그인
    @PostMapping("/login")
    public String login(@RequestParam String loginId, @RequestParam String password) {
        boolean isValid = userService.login(loginId, password);
        if (isValid) {
            return "로그인 성공!";
        } else {
            return "로그인 실패!";
        }
    }
}