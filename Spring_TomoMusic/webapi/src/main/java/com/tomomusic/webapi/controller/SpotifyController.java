package com.tomomusic.webapi.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.tomomusic.webapi.Service.SpotifyService;

@RestController
@RequestMapping("/spotify")
public class SpotifyController {

    @Autowired
    private SpotifyService spotifyService;

    @GetMapping("/album/{albumId}")
    public ResponseEntity<String> getAlbumInfo(@RequestHeader("Authorization") String accessToken,
            @PathVariable String albumId) {
        String albumInfo = spotifyService.getAlbumInfo(accessToken, albumId);
        return ResponseEntity.ok(albumInfo);
    }
}