import SwiftUI

class AlbumSearchViewModel: ObservableObject {
    @Published var albums: [Album] = []
    @Published var tracks: [MusicTrack] = []  // ✅ 노래(트랙) 데이터 추가
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func search(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://192.168.219.94:8085/spotify/search?query=\(encodedQuery)&type=album,track") else {
            DispatchQueue.main.async {
                self.errorMessage = "잘못된 검색어입니다."
            }
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "네트워크 오류: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "데이터를 불러올 수 없습니다."
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.albums = decodedResponse.albums.items
                    self.tracks = decodedResponse.tracks.items  // ✅ 트랙 데이터 저장
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "데이터를 처리하는 중 오류가 발생했습니다."
                }
            }
        }.resume()
    }
}
