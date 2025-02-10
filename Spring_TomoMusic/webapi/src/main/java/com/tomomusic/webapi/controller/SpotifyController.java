package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/spotify")
public class SpotifyController {

    @Value("${spotify.client-id}")
    private String clientId;

    @Value("${spotify.client-secret}")
    private String clientSecret;

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private static final String API_BASE_URL = "https://api.spotify.com/v1/";

    // 🎯 앨범 & 트랙 검색 API
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(@RequestParam String query) {
        String accessToken = getAccessToken();
        return ResponseEntity.ok(fetchAlbumsAndTracks(query, accessToken));
    }

    // ✅ 앨범 & 트랙을 함께 검색하는 메서드
    private Map<String, Object> fetchAlbumsAndTracks(String query, String accessToken) {
        String url = API_BASE_URL + "search?q=" + query + "&type=album,track&limit=10";

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseSpotifyResponse(response.getBody());
    }

    // ✅ JSON 응답을 Map으로 변환 (앨범 + 트랙 포함)
    private Map<String, Object> parseSpotifyResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> result = new HashMap<>();
            result.put("albums", jsonResponse.get("albums"));
            result.put("tracks", jsonResponse.get("tracks"));

            return result;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing Spotify response", e);
        }
    }

    // ✅ Spotify Access Token 가져오는 메서드
    private String getAccessToken() {
        String credentials = clientId + ":" + clientSecret;
        String base64Credentials = new String(java.util.Base64.getEncoder().encode(credentials.getBytes()));

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Basic " + base64Credentials);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        HttpEntity<String> entity = new HttpEntity<>("grant_type=client_credentials", headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(TOKEN_URL, HttpMethod.POST, entity, String.class);

        return parseAccessToken(response.getBody());
    }

    private String parseAccessToken(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);
            return jsonResponse.get("access_token").asText();
        } catch (Exception e) {
            throw new RuntimeException("Error parsing access token response", e);
        }
    }

    // @GetMapping("/album/{id}")
    // public ResponseEntity<Map<String, Object>> getAlbumInfo(@PathVariable String
    // id) {
    // // Step 1: Access Token 가져오기
    // String accessToken = getAccessToken();

    // // Step 2: 앨범 상세 정보 가져오기
    // System.out.println(fetchAlbumDetails(id, accessToken));
    // return ResponseEntity.ok(fetchAlbumDetails(id, accessToken));
    // }
    @GetMapping("/album/{id}")
    public ResponseEntity<String> getAlbumInfo(@PathVariable String id) {
        // Step 1: Get Access Token
        String accessToken = getAccessToken();

        // Step 2: Fetch Album Info using the access token
        String albumInfo = fetchAlbumInfo(id, accessToken);
        System.out.println(albumInfo);
        return ResponseEntity.ok(albumInfo);
    }

    private String fetchAlbumInfo(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return response.getBody();
    }

    // ✅ 앨범 상세 정보를 가져오는 메서드
    private Map<String, Object> fetchAlbumDetails(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseAlbumDetailsResponse(response.getBody());
    }

    private Map<String, Object> parseAlbumDetailsResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> result = new HashMap<>();

            // 앨범 정보 추출
            result.put("id", jsonResponse.get("id").asText());
            result.put("name", jsonResponse.get("name").asText());
            result.put("release_date", jsonResponse.get("release_date").asText());
            result.put("images", jsonResponse.get("images"));

            // 앨범의 아티스트 정보 추출
            JsonNode artistsNode = jsonResponse.get("artists");
            result.put("artists", artistsNode);

            // 트랙 정보 추출 (앨범 내 트랙들)
            JsonNode tracksNode = jsonResponse.get("tracks").get("items");
            result.put("tracks", tracksNode);

            return result;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing album details response", e);
        }
    }
}