package com.tomomusic.webapi.controller;

import com.tomomusic.webapi.Service.UserService;
import com.tomomusic.webapi.entity.UserEntity;

import java.util.Optional;

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

        // 중복된 loginId가 있는지 확인
        Optional<UserEntity> existingUser = userService.getUserByLoginId(loginId);
        if (existingUser.isPresent()) {
            // 이미 존재하는 아이디일 경우
            return ResponseEntity.badRequest().body("이미 존재하는 아이디입니다.");
        }

        // 중복되지 않으면 회원가입 진행
        userService.register(loginId, password, nickname);
        return ResponseEntity.ok("회원가입 성공!");
    }

    // 로그인
    @PostMapping("/login")
    public String login(@RequestParam String loginId, @RequestParam String password) {
        boolean isValid = userService.login(loginId, password);
        System.out.println(isValid);
        if (isValid) {
            return "로그인 성공!";
        } else {
            return "아이디 또는 비밀번호가 일치하지 않습니다.";
        }
    }

    // 사용자 정보 조회
    @GetMapping("/users/{loginId}")
    public ResponseEntity<UserEntity> getUserByLoginId(@PathVariable String loginId) {
        Optional<UserEntity> user = userService.getUserByLoginId(loginId);
        if (user.isPresent()) {
            return ResponseEntity.ok(user.get());
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}