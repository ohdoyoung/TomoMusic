import Foundation

struct AlbumInfo: Codable,Identifiable {
    let id: String
    let image_url: String
    let name: String // 앨범 이름 추가

    var imageUrl: String {
        return image_url
    }
    var uniqueId: String {
            return id + (name ?? "Unknown") // name과 결합하여 고유한 ID 생성
        }
}
