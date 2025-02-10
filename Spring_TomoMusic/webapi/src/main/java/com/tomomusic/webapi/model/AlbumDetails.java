package com.tomomusic.webapi.model;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AlbumDetails {
    private String name;
    private String artist;
    private List<Track> tracks;

}