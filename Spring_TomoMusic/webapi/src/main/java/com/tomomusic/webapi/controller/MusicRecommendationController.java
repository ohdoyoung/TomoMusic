// package com.tomomusic.webapi.controller;

// import org.springframework.web.bind.annotation.*;
// import org.springframework.http.ResponseEntity;
// import org.springframework.web.client.RestTemplate;

// @RestController
// @RequestMapping("/api/music-recommendation")
// public class MusicRecommendationController {

// private final String SPOTIFY_API_URL =
// "https://api.spotify.com/v1/recommendations";
// private final String ACCESS_TOKEN = "your_spotify_access_token"; // Spotify

// @GetMapping("/recommend")
// public ResponseEntity<?> getRecommendations(@RequestParam String emotion) {
// String genre = mapEmotionToGenre(emotion); // 감정에 따라 장르 결정
// String url = buildRecommendationUrl(genre);

// RestTemplate restTemplate = new RestTemplate();
// String response = restTemplate.getForObject(url, String.class);

// return ResponseEntity.ok(response); // Spotify에서 받은 추천 결과 반환
// }

// // 감정에 따라 장르 매핑
// // 감정에 따라 장르 매핑
// private String mapEmotionToGenre(String emotion) {
// switch (emotion) {
// case "🙂": // 행복
// case "😊":
// case "😎":
// case "🥳":
// case "🤩":
// case "😇":
// case "❤️":
// case "😂":
// return "pop, party, upbeat, dance, edm, feel-good";
// case "😢": // 슬픔
// case "😴":
// case "🥺":
// case "😭":
// case "😷":
// case "😔":
// return "ballad, acoustic, lo-fi, ambient, indie, sad, slow";
// case "😜": // 에너지
// case "🤪":
// case "💪":
// case "🥶":
// return "dance, edm, rap, rock, hip-hop, energetic";
// case "🤯": // 혼란
// case "😱":
// case "😳":
// case "🤔":
// case "😡":
// return "metal, intense, alternative, electronic, dark, dramatic";
// case "😈": // 공포
// case "💀":
// return "horror, suspense, thriller, dark, eerie";
// default:
// return "pop"; // 기본 값은 pop 장르
// }
// }

// // Spotify 추천 URL 생성
// private String buildRecommendationUrl(String genre) {
// return SPOTIFY_API_URL + "?seed_genres=" + genre + "&limit=10" +
// "&access_token=" + ACCESS_TOKEN;
// }
// }