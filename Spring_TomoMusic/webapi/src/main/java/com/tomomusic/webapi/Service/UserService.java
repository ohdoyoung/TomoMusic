package com.tomomusic.webapi.Service;

import com.tomomusic.webapi.entity.UserEntity;
import com.tomomusic.webapi.mapper.UserRepository;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    // 회원가입
    public UserEntity register(String loginId, String rawPassword, String nickname) {
        // 비밀번호 암호화 없이 그대로 저장
        UserEntity user = UserEntity.builder()
                .loginId(loginId)
                .password(rawPassword) // 암호화 없이 비밀번호 저장
                .nickname(nickname)
                .build();
        return userRepository.save(user);
    }

    // 로그인 검증
    public boolean login(String loginId, String rawPassword) {
        // loginId로 사용자 조회
        UserEntity user = userRepository.findByLoginId(loginId).orElse(null);
        if (user != null) {
            // 비밀번호 평문 비교
            return rawPassword.equals(user.getPassword());
        }
        return false;
    }

    public Optional<UserEntity> getUserByLoginId(String loginId) {
        return userRepository.findByLoginId(loginId);
    }
}