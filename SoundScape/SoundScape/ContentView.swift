import SwiftUI

struct ContentView: View {
  @State private var albumName: String = ""
  @State private var artistName: String = ""
  @State private var albumImageURL: String = ""

  let albumId = "5sY6UIQ32GqwMLAfSNEaXb"  // 예시 앨범 ID

  var body: some View {
    VStack {
      if !albumName.isEmpty {
        Text("Album: \(albumName)")
        Text("Artist: \(artistName)")
        if !albumImageURL.isEmpty {
          AsyncImage(url: URL(string: albumImageURL))
            .frame(width: 200, height: 200)
        }
      } else {
        Text("Fetching album...")
      }
    }
    .onAppear {
      fetchAlbumData(albumId: albumId)
    }
  }

  func fetchAlbumData(albumId: String) {
    guard let url = URL(string: "http://localhost:8085/spotify/album/\(albumId)") else {
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let data = data {
        // JSON 파싱하여 앨범 정보 추출
        if let album = try? JSONDecoder().decode(Album.self, from: data) {
          DispatchQueue.main.async {
            self.albumName = album.name
            self.artistName = album.artists.first?.name ?? "Unknown"
            self.albumImageURL = album.images.first?.url ?? ""
          }
        }
      }
    }

    task.resume()
  }
}

//struct Album: Codable {
//  let name: String
//  let artists: [Artist]
//  let images: [Image]
//}
//
//struct Artist: Codable {
//  let name: String
//}
//
//struct Image: Codable {
//  let url: String
//}
