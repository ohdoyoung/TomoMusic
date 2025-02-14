package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/spotify")
public class SpotifyController {

    @Value("${spotify.client-id}")
    private String clientId;

    @Value("${spotify.client-secret}")
    private String clientSecret;

    private static final String TOKEN_URL = "https://accounts.spotify.com/api/token";
    private static final String API_BASE_URL = "https://api.spotify.com/v1/";
    private final String SPOTIFY_API_URL = "https://api.spotify.com/v1/recommendations";

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

    @GetMapping("/album/{id}")
    public ResponseEntity<String> getAlbumInfo(@PathVariable String id) {
        // Step 1: Get Access Token
        String accessToken = getAccessToken();

        // Step 2: Fetch Album Info using the access token
        String albumInfo = fetchAlbumInfo(id, accessToken);
        // System.out.println(albumInfo);
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

    @GetMapping("/track/{id}")
    public ResponseEntity<Map<String, Object>> getAlbumByTrackId(@PathVariable String id) {
        // Step 1: Access Token 가져오기
        String accessToken = getAccessToken();

        // Step 2: 트랙 정보를 가져와서 포함된 앨범 정보 추출
        return ResponseEntity.ok(fetchAlbumFromTrack(id, accessToken));
    }

    // ✅ 트랙 ID를 이용하여 해당 앨범 정보를 가져오는 메서드
    private Map<String, Object> fetchAlbumFromTrack(String trackId, String accessToken) {
        String url = API_BASE_URL + "tracks/" + trackId;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseTrackResponse(response.getBody());
    }

    // ✅ 트랙 응답에서 앨범 정보를 추출하는 메서드
    private Map<String, Object> parseTrackResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);
            System.out.println(jsonResponse);

            // 트랙 응답에서 앨범 정보 추출
            JsonNode albumNode = jsonResponse.get("album");

            Map<String, Object> albumInfo = new HashMap<>();
            albumInfo.put("id", albumNode.get("id").asText());
            albumInfo.put("name", jsonResponse.get("name").asText());
            // albumInfo.put("release_date", albumNode.get("release_date").asText());
            albumInfo.put("images", albumNode.get("images"));
            albumInfo.put("artists", albumNode.get("artists"));

            return albumInfo;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing track response", e);
        }
    }

    @GetMapping("/album/{id}/detail")
    public ResponseEntity<Map<String, Object>> getDetailedAlbumInfo(@PathVariable String id) {
        // Step 1: Access Token 가져오기
        String accessToken = getAccessToken();

        // Step 2: 새로운 방식으로 앨범 상세 정보 가져오기
        Map<String, Object> albumDetails = fetchDetailedAlbumInfo(id, accessToken);

        return ResponseEntity.ok(albumDetails);
    }

    private Map<String, Object> fetchDetailedAlbumInfo(String id, String accessToken) {
        String url = API_BASE_URL + "albums/" + id;

        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        HttpEntity<String> entity = new HttpEntity<>(headers);
        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class);

        return parseDetailedAlbumResponse(response.getBody());
    }

    private Map<String, Object> parseDetailedAlbumResponse(String responseBody) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            JsonNode jsonResponse = objectMapper.readTree(responseBody);

            Map<String, Object> albumInfo = new HashMap<>();

            // 기본 앨범 정보
            albumInfo.put("id", jsonResponse.get("id").asText());
            albumInfo.put("name", jsonResponse.get("name").asText());
            albumInfo.put("release_date", jsonResponse.get("release_date").asText());

            // ✅ 첫 번째 이미지 URL만 저장
            JsonNode imagesNode = jsonResponse.get("images");
            if (imagesNode != null && imagesNode.isArray() && imagesNode.size() > 0) {
                albumInfo.put("image_url", imagesNode.get(0).get("url").asText());
            } else {
                albumInfo.put("image_url", null);
            }

            // ✅ 아티스트 정보 저장 (이름 리스트로 변환)
            JsonNode artistsNode = jsonResponse.get("artists");
            List<String> artistNames = new ArrayList<>();
            if (artistsNode != null && artistsNode.isArray()) {
                for (JsonNode artist : artistsNode) {
                    artistNames.add(artist.get("name").asText());
                }
            }
            albumInfo.put("artists", artistNames);

            // ✅ 트랙 정보 정리
            JsonNode tracksNode = jsonResponse.get("tracks").get("items");
            List<Map<String, Object>> trackList = new ArrayList<>();
            if (tracksNode != null && tracksNode.isArray()) {
                for (JsonNode track : tracksNode) {
                    Map<String, Object> trackInfo = new HashMap<>();
                    trackInfo.put("id", track.get("id").asText());
                    trackInfo.put("name", track.get("name").asText());
                    trackList.add(trackInfo);
                }
            }
            albumInfo.put("tracks", trackList);

            return albumInfo;
        } catch (Exception e) {
            throw new RuntimeException("Error parsing detailed album response", e);
        }
    }

    @GetMapping("/recommend")
    public ResponseEntity<?> getRecommendations(@RequestParam String[] emotions) {
        // 감정 배열에 대해 장르 매핑을 적용
        List<String> genres = Arrays.stream(emotions)
                .map(this::mapEmotionToGenre)
                .collect(Collectors.toList());

        // Spotify Access Token 가져오기
        String accessToken = getAccessToken(); // 액세스 토큰

        // Spotify 추천 URL 생성
        String url = buildRecommendationUrl(genres, accessToken);

        // 액세스 토큰을 포함하여 추천 API 호출
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken); // Authorization 헤더에 액세스 토큰 추가

        HttpEntity<String> entity = new HttpEntity<>(headers);
        String response = restTemplate.exchange(url, HttpMethod.GET, entity, String.class).getBody();

        return ResponseEntity.ok(response); // Spotify에서 받은 추천 결과 반환
    }

    // 감정에 따라 장르를 매핑하는 메서드
    private String mapEmotionToGenre(String emotion) {
        switch (emotion) {
            case "🙂":
                return "pop"; // 행복한 감정 -> 팝
            case "😊":
                return "chill"; // 차분한 감정 -> 차분한 음악
            case "😎":
                return "rock"; // 멋진 감정 -> 록
            case "😢":
                return "sad"; // 슬픈 감정 -> 슬픈 음악
            case "😜":
                return "indie"; // 장난스러운 감정 -> 인디
            case "🥳":
                return "party"; // 파티 감정 -> 파티 음악
            case "🤩":
                return "electronic"; // 환호하는 감정 -> 전자 음악
            case "😇":
                return "classical"; // 천사 같은 감정 -> 클래식
            case "🤔":
                return "alternative"; // 생각하는 감정 -> 얼터너티브
            case "🤯":
                return "experimental"; // 충격적인 감정 -> 실험적인 음악
            case "😈":
                return "metal"; // 악마적인 감정 -> 메탈
            case "😱":
                return "horror"; // 무서운 감정 -> 호러 음악
            case "😷":
                return "lofi"; // 아픈 감정 -> 로파이
            case "😳":
                return "rb"; // 당황한 감정 -> R&B
            case "🥺":
                return "acoustic"; // 애절한 감정 -> 어쿠스틱
            case "😴":
                return "ambient"; // 피곤한 감정 -> 앰비언트
            case "💪":
                return "workout"; // 운동하는 감정 -> 운동 음악
            case "❤️":
                return "romantic"; // 사랑하는 감정 -> 로맨틱 음악
            case "🔥":
                return "trap"; // 뜨거운 감정 -> 트랩 음악
            case "😂":
                return "comedy"; // 웃긴 감정 -> 코미디
            case "😭":
                return "sad"; // 슬픈 감정 -> 슬픈 음악
            case "🥶":
                return "chill"; // 추운 감정 -> 차분한 음악
            case "🤪":
                return "party"; // 미친 감정 -> 파티 음악
            case "😡":
                return "angry"; // 화난 감정 -> 화난 음악
            case "💀":
                return "deathmetal"; // 죽음과 관련된 감정 -> 데스메탈
            default:
                return "pop"; // 기본적으로 팝 음악
        }
    }

    // Spotify 추천 API URL 빌드 (장르 목록을 사용)
    private String buildRecommendationUrl(List<String> genres, String accessToken) {
        String genreParam = String.join(",", genres); // 장르 목록을 쉼표로 연결
        return "https://api.spotify.com/v1/recommendations?seed_genres=" + genreParam +
                "&limit=2"; // 최대 2곡 추천
    }
}