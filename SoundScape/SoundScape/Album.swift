//
//  Album.swift
//  SoundScape
//
//  Created by 오도영 on 1/25/25.
//

import Foundation
import SwiftUI

struct SpotifySearchResponse: Codable {
    let albums: AlbumList
}

struct AlbumList: Codable {
    let items: [Album]
}

struct Album: Codable, Identifiable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let artists: [Artist]

    var firstImageURL: String {
        images.first?.url ?? "https://via.placeholder.com/300" // 기본 이미지 URL 설정
    }

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}

struct SpotifyImage: Codable {
    let url: String
}

struct Artist: Codable {
    let name: String
}
