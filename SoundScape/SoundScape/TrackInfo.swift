import Foundation
struct TrackInfo: Codable {
    let name: String
    let artists: [Artist]
    let album: Album
}
