package com.tomomusic.webapi.mapper;

import org.springframework.data.jpa.repository.JpaRepository;

import com.tomomusic.webapi.entity.UserEntity;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByLoginId(String loginId);
}