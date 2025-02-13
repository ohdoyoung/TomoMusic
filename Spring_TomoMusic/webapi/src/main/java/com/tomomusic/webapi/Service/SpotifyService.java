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

    private static final String SPOTIFY_API_URL = "https://api.spotify.com/v1/tracks/";

    public String getAlbumInfo(String accessToken, String albumId) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken); // 토큰을 Authorization 헤더에 추가

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(ALBUM_URL, HttpMethod.GET, entity, String.class,
                albumId);

        return response.getBody(); // JSON 형식으로 반환
    }

    public String getTrackInfo(String trackId, String accessToken) {
        // 요청 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        // GET 요청을 보내기 위한 엔티티 설정
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // Spotify API로 요청 보내기
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(SPOTIFY_API_URL + trackId, HttpMethod.GET, entity,
                String.class);

        // 결과 반환
        return response.getBody();
    }
}