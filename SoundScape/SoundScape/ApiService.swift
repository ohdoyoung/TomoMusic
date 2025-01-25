import Foundation

class APIService {
  static let shared = APIService()

  private let baseURL = "https://api.spotify.com/v1/search"

  func fetchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
    let urlString = "\(baseURL)?q=\(query)&type=album"

    guard let url = URL(string: urlString) else {
      completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
      return
    }

    var request = URLRequest(url: url)
    request.addValue("Bearer YOUR_SPOTIFY_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")  // OAuth2 인증 토큰 추가

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let data = data else {
        completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
        return
      }

      do {
        let albumSearchResponse = try JSONDecoder().decode(AlbumSearchResponse.self, from: data)
        completion(.success(albumSearchResponse.albums.items))
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
  }
}
