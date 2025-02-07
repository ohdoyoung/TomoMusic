package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/spotify")
public class SpotifyController {

    @Value("${spotify.client-id}")
    private String clientId;

    @Value("${spotify.client-secret}")
    private String clientSecret;

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private static final String API_BASE_URL = "https://api.spotify.com/v1/";

    // 앨범 정보 가져오기
    @GetMapping("/album/{id}")
    public ResponseEntity<String> getAlbumInfo(@PathVariable String id) {
        // Step 1: Get Access Token
        String accessToken = getAccessToken();

        // Step 2: Fetch Album Info using the access token
        String albumInfo = fetchAlbumInfo(id, accessToken);
        return ResponseEntity.ok(albumInfo);
    }

    // Step 1: access token 가져오기
    private String getAccessToken() {
        String credentials = clientId + ":" + clientSecret;
        String base64Credentials = new String(java.util.Base64.getEncoder().encode(credentials.getBytes()));

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Basic " + base64Credentials);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<String> entity = new HttpEntity<>("grant_type=client_credentials", headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(TOKEN_URL, HttpMethod.POST, entity, String.class);

        // JSON 응답에서 access_token을 파싱 (Jackson 사용)
        String accessToken = parseAccessToken(response.getBody());
        return accessToken;
    }

    // JSON 응답에서 access_token을 추출하는 메서드 (Jackson 사용)
    private String parseAccessToken(String responseBody) {
        try {
            // ObjectMapper를 사용하여 JSON을 파싱
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);
            return jsonResponse.get("access_token").asText();
        } catch (Exception e) {
            throw new RuntimeException("Error parsing access token response", e);
        }
    }

    // Step 2: access token을 사용해 앨범 정보 가져오기
    private String fetchAlbumInfo(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return response.getBody();
    }

    @GetMapping("/search")
    public ResponseEntity<String> searchAlbums(@RequestParam String query) {
        // Step 1: Access Token 가져오기
        String accessToken = getAccessToken();

        // Step 2: Spotify API에서 앨범 검색
        String searchResults = fetchAlbumsByQuery(query, accessToken);
        return ResponseEntity.ok(searchResults);
    }

    // Step 2: Spotify API에서 앨범 검색
    private String fetchAlbumsByQuery(String query, String accessToken) {
        String url = API_BASE_URL + "search?q=" + query + "&type=album&limit=10";

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return response.getBody();
    }
}
