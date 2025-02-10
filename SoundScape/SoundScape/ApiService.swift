import Foundation

class APIService {
    static let shared = APIService()
    private init() {}
    
    private let backendURL = "http://localhost:8085/spotify" // 백엔드 API URL
    
    // 앨범 목록을 가져오는 함수
    func fetchAlbums(query: String, completion: @escaping (Result<[Album], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(backendURL)/search?query=\(encodedQuery)") else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "HTTP Error", code: (response as? HTTPURLResponse)?.statusCode ?? -1, userInfo: nil)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                }
                return
            }
            
            do {
                // JSONDecoder를 사용하여 응답을 디코딩합니다
                let decodedResponse = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedResponse.albums.items)) // 검색된 앨범 목록 반환
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    
    // 이미 만들어진 access token fetch 함수 사용
    static func fetchAlbumDetails(for albumId: String, completion: @escaping (AlbumDetails?) -> Void) {
        //        fetchAccessToken { accessToken in
        //            guard let accessToken = accessToken else {
        //                print("Failed to retrieve access token")
        //                completion(nil)
        //                return
        //            }
        
        let url = URL(string: "http://localhost:8085/spotify/album/\(albumId)")! // Spring 서버의 /spotify/album/{id} 엔드포인트 (로컬 서버)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        //            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch album details: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for album details.")
                completion(nil)
                return
            }
            
            do {
                let albumDetails = try JSONDecoder().decode(AlbumDetails.self, from: data)
                completion(albumDetails)
            } catch {
                print("Error decoding album details: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}

// 서버에서 access token을 가져오는 함수 (기존 코드 그대로 사용)
//    static func fetchAccessToken(completion: @escaping (String?) -> Void) {
//        let url = URL(string: "http://localhost:8085/spotify/token")! // Spring 서버의 /spotify/token 엔드포인트 (로컬 서버)
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Failed to fetch access token: \(error)")
//                completion(nil)
//                return
//            }
//
//            guard let data = data else {
//                print("No data received for access token.")
//                completion(nil)
//                return
//            }
//
//            do {
//                // JSON 응답에서 accessToken을 추출
//                let jsonResponse = try JSONDecoder().decode([String: String].self, from: data)
//                let accessToken = jsonResponse["accessToken"]
//                completion(accessToken)
//            } catch {
//                print("Error decoding access token response: \(error)")
//                completion(nil)
//            }
//        }
//        task.resume()
//    }

