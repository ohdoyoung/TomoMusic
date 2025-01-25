//
//  Album.swift
//  SoundScape
//
//  Created by 오도영 on 1/25/25.
//

import Foundation
import SwiftUI

// 앨범 응답 구조체
struct AlbumSearchResponse: Codable {
  let albums: AlbumList
}

// 앨범 리스트 구조체
struct AlbumList: Codable {
  let items: [Album]
}

// 앨범 정보 구조체
struct Album: Codable, Identifiable {
  let id: String
  let name: String
  let artists: [Artist]
  let images: [Image]
}

// 아티스트 정보 구조체
struct Artist: Codable {
  let name: String
}

// 이미지 정보 구조체
struct Image: Codable {
  let url: String
}
