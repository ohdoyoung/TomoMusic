package com.tomomusic.webapi.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Track {
    private String name;
    private String previewUrl;

    // getters and setters
}