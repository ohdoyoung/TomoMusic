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
    // 로그인 처리 로직 예시
    public boolean login(String loginId, String password) {
        Optional<UserEntity> user = userRepository.findByLoginId(loginId);

        if (user.isPresent()) {
            UserEntity userEntity = user.get();

            // 비밀번호가 평문이라면, userEntity.getPassword()와 직접 비교
            if (userEntity.getPassword().equals(password)) {
                return true; // 비밀번호 일치
            }

        }

        return false; // 로그인 실패
    }

    public Optional<UserEntity> getUserByLoginId(String loginId) {
        return userRepository.findByLoginId(loginId);
    }
}