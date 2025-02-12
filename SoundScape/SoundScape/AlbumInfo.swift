import Foundation

struct AlbumInfo: Codable {
    let id: String
    let image_url: String
    let name: String // 앨범 이름 추가

    var imageUrl: String {
        return image_url
    }
}
