package com.tomomusic.webapi.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

@RestController
@RequestMapping("/auth")
public class SpotifyAuthController {

    @Value("${spotify.client-id}")
    private String clientId;

    @Value("${spotify.client-secret}")
    private String clientSecret;

    @Value("${spotify.redirect-uri}")
    private String redirectUri;

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";

    @GetMapping("/callback")
    public ResponseEntity<String> callback(@RequestParam("code") String code) {
        // access token 요청을 위한 HttpPost 설정
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        // 파라미터 준비
        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("grant_type", "authorization_code");
        map.add("code", code);
        map.add("redirect_uri", redirectUri);
        map.add("client_id", clientId);
        map.add("client_secret", clientSecret);

        // 토큰 요청
        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(map, headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(TOKEN_URL, HttpMethod.POST, entity, String.class);

        // 받은 토큰을 통해 API 호출
        String accessToken = parseAccessToken(response.getBody());
        return ResponseEntity.ok("Access Token: " + accessToken);
    }

    private String parseAccessToken(String responseBody) {
        try {
            // JSON 응답을 파싱하여 access_token 추출
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonNode = objectMapper.readTree(responseBody);
            return jsonNode.get("access_token").asText();
        } catch (Exception e) {
            e.printStackTrace();
            return "Error parsing access token";
        }
    }
}