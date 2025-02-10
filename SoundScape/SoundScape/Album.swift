import Foundation

// ✅ 앨범 검색 응답
struct SpotifySearchResponse: Codable {
    let albums: AlbumList
    let tracks: TrackResponse  // ✅ 트랙 데이터 추가

}

struct TrackResponse: Codable {
    let items: [MusicTrack]
}

struct AlbumList: Codable {
    let items: [Album]
}

// ✅ 앨범 개별 정보
struct Album: Codable, Identifiable {
    let id: String
    let name: String
    let images: [SpotifyImage]
    let artists: [Artist]

    var firstImageURL: String {
        images.first?.url ?? "https://via.placeholder.com/300" // 기본 이미지
    }

    var artistNames: String {
        artists.map { $0.name }.joined(separator: ", ")
    }
}


// ✅ 아티스트 정보
struct Artist: Codable {
    let name: String
}

// ✅ 이미지 정보
struct SpotifyImage: Codable {
    let url: String
}

struct SearchResult: Codable {
    let albums: [Album]
    let tracks: [MusicTrack]
}
