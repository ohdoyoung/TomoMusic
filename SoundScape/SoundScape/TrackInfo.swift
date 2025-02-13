import Foundation

struct TrackInfo: Decodable {
    var id: String
    var name: String
    var imageUrl: String?  // 첫 번째 이미지 URL을 담을 변수
    
    // images 배열을 추가
    var images: [ImageData]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case images
    }
    
    struct ImageData: Decodable {
        var url: String
        var width: Int
        var height: Int
    }
    
    // 이미지 URL을 첫 번째 이미지의 URL로 설정하는 init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        images = try container.decodeIfPresent([ImageData].self, forKey: .images)
        // 첫 번째 이미지를 imageUrl로 설정
        imageUrl = images?.first?.url
    }
}
