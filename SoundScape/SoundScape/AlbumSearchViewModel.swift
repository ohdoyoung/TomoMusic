import SwiftUI

class AlbumSearchViewModel: ObservableObject {
    @Published var albums: [Album] = []   // ✅ Album 직접 사용
    @Published var isLoading: Bool = false  // ✅ 로딩 상태 추가
    @Published var errorMessage: String? = nil  // ✅ 에러 메시지 추가

    func searchAlbums(query: String) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:8085/spotify/search?query=\(encodedQuery)") else {
            DispatchQueue.main.async {
                self.errorMessage = "잘못된 검색어입니다."
            }
            return
        }

        isLoading = true  // ✅ API 요청 시작할 때 로딩 상태 변경

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false  // ✅ 응답이 오면 로딩 상태 해제
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
                    self.errorMessage = nil  // ✅ 성공 시 에러 메시지 초기화
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "데이터를 처리하는 중 오류가 발생했습니다."
                }
            }
        }.resume()
    }
}
