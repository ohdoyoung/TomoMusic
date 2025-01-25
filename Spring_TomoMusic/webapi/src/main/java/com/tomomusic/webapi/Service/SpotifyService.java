package com.tomomusic.webapi.Service;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class SpotifyService {

    private static final String ALBUM_URL = "https://api.spotify.com/v1/albums/{albumId}";

    public String getAlbumInfo(String accessToken, String albumId) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken); // 토큰을 Authorization 헤더에 추가

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(ALBUM_URL, HttpMethod.GET, entity, String.class,
                albumId);

        return response.getBody(); // JSON 형식으로 반환
    }
}